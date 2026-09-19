---
title: Retrying what is worth retrying
requires: [verify:retry-and-filter]
---

# Retrying what is worth retrying

You built a `@retry` in workshop four. This one adds the argument that
makes it safe to use: which exceptions are worth another attempt.

```{cell-insert}
:id: insert-retry
:path: {{ notebook }}
:tags: [retry]
:run: true
tries = []

def retry(attempts=3, retry_on=(ConnectionError,), delay=0.01):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, attempts + 1):
                try:
                    return func(*args, **kwargs)
                except retry_on:
                    tries.append(attempt)
                    if attempt == attempts:
                        raise
                    time.sleep(delay * attempt)
        return wrapper
    return decorator

state = {"calls": 0}

@retry()
def flaky():
    state["calls"] += 1
    if state["calls"] < 3:
        raise ConnectionError("down")
    return "connected"

connected = flaky()

print("result:", connected)
print("failed attempts:", tries)
```

Two failures, then success. `except retry_on` catches a tuple of
exception types, which is ordinary `except` syntax with the tuple in a
variable rather than written out.

Now the case that matters: an exception that retrying cannot possibly
help with.

```{cell-insert}
:id: insert-filter
:path: {{ notebook }}
:tags: [filter]
:run: true
tries.clear()

@retry()
def bad_input():
    raise ValueError("not retryable")

try:
    bad_input()
    filtered = "no error"
except ValueError as error:
    filtered = str(error)

print("raised straight away:", filtered)
print("attempts made       :", tries)
```

No attempts recorded at all. The `ValueError` did not match `retry_on`,
so it was never caught and went straight to the caller on the first try.

That is the whole argument for naming the exceptions. Bad input fails
identically every time, so retrying it turns an instant, clear error
into a slow one, and under backoff a validation error can take seconds
to arrive. Worse, retrying a request that already succeeded before
failing can repeat an action nobody wanted repeated. Retry the failures
that might not happen again: a dropped connection, a timeout, a lock
that was briefly held.

The growing `delay * attempt` matters for the same reason as in workshop
four. A service that is struggling is made worse by a client that
retries immediately, and made much worse by many of them.

```{verify}
:id: retry-and-filter
:label: The flaky call recovered and the unretryable one did not retry
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed filter
connected == "connected" and filtered == "not retryable" and tries == []
```
