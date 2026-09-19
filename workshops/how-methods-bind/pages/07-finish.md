---
title: What you know now
requires: [quiz:what-get-returns]
---

# What you know now

`obj.method` is not a lookup that happens to pass `self`. It is a lookup
that finds a descriptor and calls its `__get__`, and the bound method
you end up with is simply what that `__get__` returned.

Which is why a class-based decorator broke on methods. It replaced the
function with an instance that had no `__get__`, so the lookup had
nothing to call and handed the instance straight back, with the
instance never involved at all.

The shape that fixes it:

```python
class Decorator:
    def __init__(self, func):
        functools.update_wrapper(self, func)
        self.func = func

    def __call__(self, *args, **kwargs):
        return self.func(*args, **kwargs)

    def __set_name__(self, owner, name):
        self.attribute = name

    def __get__(self, instance, owner=None):
        if instance is None:
            return self
        bound = BoundForm(self.func, instance)
        instance.__dict__[self.attribute] = bound
        return bound
```

Two separate jobs, which is worth keeping apart. `__get__` fixes
*binding*. What `__get__` returns fixes *state*: return the decorator
itself and every object shares it, return something built for the
instance and each object gets its own.

One condition comes with the caching. Writing into the instance
dictionary shadows the class attribute, so this shape has to be the
outermost decorator. Put anything above it and it either fails at once,
because `__set_name__` is called only on objects assigned directly in a
class body, or, where the outer decorator is a descriptor that forwards
`__set_name__`, quietly drops out of the chain after the first call.
`functools.cached_property` carries the same restriction.

And the protocol is not about decorators. `@property`, `@staticmethod`
and `@classmethod` are all descriptors, and you can write one for a
validated attribute without a decorator in sight.

```{quiz}
:id: what-get-returns
:title: What the lookup returns
:shuffle: true
question: "A class-based decorator defines `__get__` returning `types.MethodType(self, instance)`. Calls bind correctly, but every object shares one count. Why?"
options:
  - text: "Because `types.MethodType` copies the instance rather than referencing it."
    explanation: "It holds a reference, and that reference is what makes `self` arrive correctly. The sharing is not about the instance."
  - text: "Because the decorator runs once for the class, so `self` is a single object that every bound method points back to."
    correct: true
  - text: "Because `__get__` is only called the first time the attribute is looked up."
    explanation: "It is called on every lookup, unless something has been stored in the instance dictionary to shadow it. Either way, it keeps returning methods bound to the same decorator."
  - text: "Because `functools.update_wrapper` shares the `__dict__` between instances."
    explanation: "It copies entries from the wrapped function once, at decoration time. The count lives on the decorator instance, which is the thing being shared."
explanation: "The decorator is applied once, when the class body runs, so there is exactly one instance holding `count`. Binding creates a new method object per lookup, but all of them point at that one decorator. Per-object state needs `__get__` to return something built for the instance."
```

## Where this goes next

That is the mechanism underneath the last three workshops, and the last
piece of how decorators actually work.

What is left is the one target you have not decorated. You have put
decorators on functions, on methods, and written them as classes. The
very first workshop showed you `@dataclass`, applied to a class rather
than a function, and nothing since has explained what that does.

**Decorating classes** is next.

Press Finish below to move on.
