---
title: A decorator that is a class
requires: [verify:counting-works]
---

# A decorator that is a class

Two methods are all it takes. `__init__` receives the function at
decoration time and keeps it. `__call__` runs on every call and does
whatever the wrapper used to do.

```{cell-insert}
:id: insert-counted
:path: {{ notebook }}
:tags: [counted]
:run: true
class Counted:
    """Count how many times the decorated function is called."""

    def __init__(self, func):
        self.func = func
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(*args, **kwargs)

@Counted
def ping():
    """say pong"""
    return "pong"

ping()
ping()
result = ping()

print("returned:", result)
print("count   :", ping.count)
print("ping is a:", type(ping).__name__)
```

`ping` is no longer a function at all. It is a `Counted` object, and
calling it runs `__call__`.

Line the two versions up and the correspondence is exact. `__init__` is
the body of the decorator, the part that ran once. `__call__` is the
wrapper, the part that runs every time. `self.func` is what the closure
cell held. `self.count` is what `wrapper.call_count` was.

The difference is where the state lives. `ping.count` is an ordinary
attribute on an ordinary object, which you can read, reset, or watch in
a debugger. In workshop two the same count sat on a function object as
an attribute the decorator invented, which worked but is not somewhere
a reader would think to look.

```{verify}
:id: counting-works
:label: The class-based decorator counted the calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed counted
result == "pong" and ping.count == 3 and type(ping).__name__ == "Counted"
```

```{hint}
:title: One instance per decorated function
`@Counted` calls `Counted(ping)` once, so each decorated function gets
its own instance with its own count, exactly as each call to a
function-based decorator produced its own closure. Decorate a second
function and it counts separately.
```
