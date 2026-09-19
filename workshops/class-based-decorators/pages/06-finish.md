---
title: What you know now
requires: [quiz:which-method]
---

# What you know now

A decorator can be a class, because `@` calls whatever it is given and
keeps the result, and a class is callable.

Two shapes, distinguished only by which method receives the function:

```python
class Counted:              # the instance replaces the function
    def __init__(self, func):
        functools.update_wrapper(self, func)
        self.func = func

    def __call__(self, *args, **kwargs):
        return self.func(*args, **kwargs)

class RateLimit:            # the instance is the decorator
    def __init__(self, calls):
        self.calls = calls

    def __call__(self, func):
        ...
        return wrapper
```

Reach for a class when there is state worth naming, which reads better
as an attribute than as a closure cell, or when settings would otherwise
need a third level of nesting. Use `functools.update_wrapper(self, func)`
in `__init__`, or the decorated function has no `__name__` and reports
the decorator class's docstring as its own.

And remember what it cannot do: an instance does not bind, so this kind
of decorator does not work on methods, and there is one instance per
decorated function rather than per object. Both of those are fixable,
and the next workshop is where.

```{quiz}
:id: which-method
:title: Which method gets the function
:shuffle: true
question: "In `@RateLimit(calls=2)`, which method of RateLimit receives the function being decorated?"
options:
  - text: "`__call__`, because `RateLimit(calls=2)` has already consumed `__init__`."
    correct: true
  - text: "`__init__`, as it does for `@Counted`."
    explanation: "That is true of `@Counted`, where the class is named bare. Here the parentheses mean `__init__` runs first with the settings, so the function has to arrive somewhere else."
  - text: "Both: `__init__` gets it first, then `__call__` gets it again."
    explanation: "The function is passed exactly once. `__init__` saw only `calls=2`."
  - text: "Neither; the function is passed to the wrapper when it is called."
    explanation: "The wrapper receives the call's arguments. The function itself must be handed over at decoration time, or the decorator would have nothing to wrap."
explanation: "`@RateLimit(calls=2)` runs `RateLimit(calls=2)` first, so `__init__` takes the settings and the resulting instance is then applied to the function, which is `__call__`."
```

## Where this goes next

You can now write a decorator as a function or as a class, configure it,
stack it, keep its identity, and put it on a method without being
surprised.

What is still unexplained is the thing that broke on the last page. The
next workshop takes `obj.method` apart, shows what actually ties an
instance to a function, and uses it to fix the decorator you have just
watched fail.

**How methods bind** is next.

Press Finish below to move on.
