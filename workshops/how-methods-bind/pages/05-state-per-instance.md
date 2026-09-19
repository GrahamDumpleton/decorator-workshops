---
title: State per instance
requires: [verify:per-instance]
---

# State per instance

If one decorator instance cannot hold per-object state, then `__get__`
has to hand back something that can: a small object built for this
instance, holding its own count.

Two pieces. A bound counter that knows its instance, and a descriptor
whose only job is to produce one.

```{cell-insert}
:id: insert-per-instance
:path: {{ notebook }}
:tags: [per-instance]
:run: true
class BoundCounter:
    """One counter, for one object."""

    def __init__(self, func, instance):
        functools.update_wrapper(self, func)
        self.func = func
        self.instance = instance
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(self.instance, *args, **kwargs)

class CountedPerObject:
    def __init__(self, func):
        functools.update_wrapper(self, func)
        self.func = func

    def __set_name__(self, owner, name):
        self.attribute = name

    def __get__(self, instance, owner=None):
        if instance is None:
            return self
        counter = BoundCounter(self.func, instance)
        instance.__dict__[self.attribute] = counter
        return counter

class Svc3:
    def __init__(self, name):
        self.name = name

    @CountedPerObject
    def call(self):
        return "ok"

one, two = Svc3("one"), Svc3("two")

one.call()
one.call()
two.call()

counts = (one.call.count, two.call.count)

print("one:", counts[0], "| two:", counts[1])
print("cached on the instance:", "call" in one.__dict__)
```

Separate counts, because each object got its own `BoundCounter` the
first time it looked the attribute up.

Two things are doing work here that are worth naming.

`__set_name__` is called by Python when the class body finishes, and it
tells the descriptor the name it was assigned to. That is how
`CountedPerObject` knows to store its counter under `call` without
being told twice.

The line that stores into `instance.__dict__` is not just a cache, it is
what makes the counter survive. Without it, every lookup would build a
fresh `BoundCounter` with a count of zero, and `one.call.count` would
always be `1`. Storing it works because this class defines only
`__get__`, which makes it a *non-data* descriptor, and for those the
instance dictionary wins on later lookups. So the descriptor runs once
per object and then steps out of the way.

```{verify}
:id: per-instance
:label: Each object counts its own calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed per-instance
counts == (2, 1) and "call" in one.__dict__
```

```{hint}
:title: Data and non-data descriptors
Define `__set__` or `__delete__` as well and it becomes a *data*
descriptor, which takes precedence over the instance dictionary and is
consulted on every lookup. That is what you want for a managed
attribute, as on the next page, and what you must avoid here, where
stepping aside after the first lookup is the whole trick.
```

```{hint}
:title: This one has to be the outermost decorator
Writing into `instance.__dict__[self.attribute]` shadows the *class*
attribute, which is only the right thing to do while this descriptor is
the class attribute. Stack another decorator on top and it no longer
is.

With an ordinary function decorator above it, the descriptor is wrapped
rather than assigned, so Python never calls its `__set_name__` and the
first call raises `TypeError: 'CountedPerObject' object is not
callable`. Loud, and easy to diagnose.

The dangerous case is an outer decorator that is itself a descriptor
and forwards `__set_name__`. That one looks like it works: every call
returns the right answer, but the cached counter shadows the outer
decorator from the second lookup onwards, so it runs once and then
silently stops taking part. `functools.cached_property` carries the
same restriction, for the same reason.
```
