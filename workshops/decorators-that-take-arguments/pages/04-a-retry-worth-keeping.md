---
title: A retry worth keeping
requires: [verify:retry-works]
---

# A retry worth keeping

`@repeat(3)` was a demonstration. This one you could put in a project.

`@retry` calls the function, and if it raises the exception you named,
waits a moment and tries again. It gives up by letting the last failure
through, which matters: a retry that swallows the error leaves the
caller believing the work was done.

```{cell-insert}
:id: insert-retry
:path: {{ notebook }}
:tags: [retry]
:run: true
import time

attempts = []

def retry(max_attempts=3, delay=0.01):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except ConnectionError:
                    attempts.append(attempt)
                    if attempt == max_attempts:
                        raise
                    time.sleep(delay * attempt)
        return wrapper
    return decorator

state = {"calls": 0}

@retry(max_attempts=3, delay=0.01)
def flaky():
    state["calls"] += 1
    if state["calls"] < 3:
        raise ConnectionError("connection refused")
    return "connected"

outcome = flaky()

print("result:", outcome)
print("attempts that failed:", attempts)
```

Two failures, then success, and the caller never knew. `delay * attempt`
makes each wait longer than the last, which is what you want against a
service that is struggling: hammering it every ten milliseconds is how a
retry turns a blip into an outage.

Now the case that matters more. When the attempts run out, the
exception has to reach the caller.

```{cell-insert}
:id: insert-gives-up
:path: {{ notebook }}
:tags: [gives-up]
:run: true
attempts.clear()

@retry(max_attempts=2, delay=0.01)
def always_fails():
    raise ConnectionError("still down")

try:
    always_fails()
    gave_up = "no error"
except ConnectionError as error:
    gave_up = str(error)

print("gave up with:", gave_up)
print("attempts:", attempts)
```

`raise` on the last attempt re-raises the exception being handled, with
its original traceback. Delete that line and `wrapper` falls out of the
loop, returns `None`, and a caller that asked for a connection gets
nothing at all and no hint why.

```{verify}
:id: retry-works
:label: The retry recovers, and gives up loudly when it cannot
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed gives-up
outcome == "connected" and gave_up == "still down" and attempts == [1, 2]
```

```{hint}
:title: Why ConnectionError and not Exception
Because retrying is only sensible for failures that might not happen
next time. A `ValueError` from bad input will fail identically three
times, so catching everything turns a clear error into a slow one.
Naming the exceptions worth retrying is part of the decorator's
configuration, and a real one takes them as an argument.
```
