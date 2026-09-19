---
title: The one that cannot
requires: [verify:still-broken]
---

# The one that cannot

That is what a function does when it is looked up. A decorator written
as a class does none of it.

Writing one as a class replaces the function with an instance of that
class. The instance is callable, so it stands in for the function well
enough by itself, but it is not a function, and nothing has given it a
`__get__`.

`Counted` below is that decorator: it counts calls, and copies the
wrapped function's name and docstring with `update_wrapper`. On a plain
function it works perfectly. Here it is on a method.

```{cell-insert}
:id: insert-counted
:path: {{ notebook }}
:tags: [counted]
:run: true
class Counted:
    """Count how many times the decorated function is called."""

    def __init__(self, func):
        functools.update_wrapper(self, func)
        self.func = func
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(*args, **kwargs)

class Svc:
    def __init__(self, name):
        self.name = name

    @Counted
    def call(self):
        return "ok"

svc = Svc("one")

try:
    svc.call()
    problem = "no error"
except TypeError as error:
    problem = str(error)

print("Svc.call is a:", type(Svc.call).__name__)
print("problem     :", problem)
print("lookup changed nothing:", Svc.call is svc.call)
```

The last line is the one to look at. `Svc.call is svc.call` is `True`.

On `Service`, whose `call` is an ordinary undecorated method, those two
lookups gave different objects: a function from the class, a method from
the instance. Here they give the same object, because a `Counted`
instance has no `__get__`, so the interpreter has nothing to call and
hands back exactly what it found.

Nothing was ever going to pass `self`. The instance is not lost
somewhere inside the wrapper, it was never involved: `svc.call()` calls
`Counted.__call__` with no arguments at all, which calls the original
`call` with no arguments, and `call` wants `self`.

That is also why the error names `self` rather than a later argument.
When a function decorator breaks on a method, every argument shifts
along by one and the *last* one falls off the end. Here nothing shifted,
because nothing was passed.

```{verify}
:id: still-broken
:label: The instance was never passed, and the lookup did nothing
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed counted
type(Svc.call).__name__ == "Counted" and "missing 1 required positional argument" in problem and Svc.call is svc.call
```
