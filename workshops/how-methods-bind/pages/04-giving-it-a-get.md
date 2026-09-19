---
title: Giving it a __get__
requires: [verify:binds-now]
---

# Giving it a `__get__`

The decorator needs to do what a function does on lookup. That is one
method, and `types.MethodType` builds the same kind of object a function
would have returned: it takes something callable and an instance, and
ties them together.

```{cell-insert}
:id: insert-with-get
:path: {{ notebook }}
:tags: [with-get]
:run: true
class CountedBound:
    """Count calls, and bind like a function does."""

    def __init__(self, func):
        functools.update_wrapper(self, func)
        self.func = func
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(*args, **kwargs)

    def __get__(self, instance, owner=None):
        if instance is None:
            return self
        return types.MethodType(self, instance)

class Svc2:
    def __init__(self, name):
        self.name = name

    @CountedBound
    def call(self):
        return "ok"

first, second = Svc2("first"), Svc2("second")

first.call()
first.call()
second.call()

shared = Svc2.__dict__["call"].count

print("first.call is a:", type(first.call).__name__)
print("count on the decorator:", shared)
```

Binding works. `first.call` is a `method` again, the instance arrives as
`self`, and the calls succeed.

The `if instance is None: return self` line is what keeps `Svc2.call`
working: looked up on the class there is no instance to bind to, and
returning the decorator itself is what a function does in the same
situation.

But look at the count. Three calls went through: two on `first`, one on
`second`, and the count says `3` for both of them together.

That is the second problem, and `__get__` on its own did not fix it. The
decorator runs once, when the class body is executed, so there is one
`CountedBound` instance for the whole class. `types.MethodType(self,
instance)` binds a new method object to that same single decorator, so
every instance shares its state.

Fixing it is not a matter of having `__get__`. It is a matter of what
`__get__` returns.

```{verify}
:id: binds-now
:label: It binds, and the count is shared across instances
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed with-get
type(first.call).__name__ == "method" and shared == 3
```
