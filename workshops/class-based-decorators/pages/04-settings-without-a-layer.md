---
title: Settings without an extra layer
requires: [verify:rate-limit]
---

# Settings without an extra layer

Workshop four needed three nested functions to write `@repeat(3)`: one
for the settings, one for the function, one for the call.

A class already has somewhere to put settings. `__init__` takes them,
`__call__` takes the function, and there is no third level, because an
instance holding configuration is what the middle layer was faking.

```{cell-insert}
:id: insert-ratelimit
:path: {{ notebook }}
:tags: [ratelimit]
:run: true
class RateLimit:
    """Allow only so many calls, then refuse."""

    def __init__(self, calls):
        self.calls = calls

    def __call__(self, func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            wrapper.used += 1
            if wrapper.used > self.calls:
                raise RuntimeError("rate limit exceeded")
            return func(*args, **kwargs)

        wrapper.used = 0
        return wrapper

@RateLimit(calls=2)
def fetch():
    return "data"

first = fetch()
second = fetch()

try:
    fetch()
    third = "no error"
except RuntimeError as error:
    third = str(error)

print("first :", first)
print("second:", second)
print("third :", third)
```

Read `@RateLimit(calls=2)` the way you read `@repeat(3)`.
`RateLimit(calls=2)` runs first and builds an instance holding
`calls = 2`. That instance is then applied to `fetch`, which calls
`__call__`, which returns the wrapper.

Notice which layers disappeared and which did not. The settings layer is
now `__init__`, so there are two levels rather than three. But
`__call__` still returns a function rather than `self`, deliberately:
that keeps `fetch` an ordinary function, so it still binds correctly as
a method, which is the trap the next page is about.

```{verify}
:id: rate-limit
:label: The limit allowed two calls and refused the third
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed ratelimit
first == "data" and second == "data" and third == "rate limit exceeded"
```

```{hint}
:title: Two shapes, and when to use which
A class whose `__call__` takes the function, as here, is a configurable
decorator: the instance is the decorator. A class whose `__init__` takes
the function, as `Counted` does, is the decorated function itself. Both
are common, they look almost identical, and the difference is simply
which method receives the function being decorated.
```
