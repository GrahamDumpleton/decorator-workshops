---
title: When the function raises
requires: [verify:finally-runs, verify:branches-and-timer]
---

# When the function raises

Every wrapper on the last four pages has the same bug, and it is the one
that bites in production rather than in a tutorial.

`result = func(*args, **kwargs)` is a call that can fail. When it does,
the exception travels straight out of the wrapper, and every line below
that call is skipped. The "after" line never prints. The timer never
reports. The call you would most want to know about is the one your
decorator says nothing about.

Record what actually runs, rather than printing it, so you can see
exactly how far the wrapper got. This is the same `announce` as before
with a list in place of the prints.

```{cell-insert}
:id: insert-raises
:path: {{ notebook }}
:tags: [raises]
:run: true
without_finally = []

def announce(func):
    def wrapper(*args, **kwargs):
        without_finally.append("before")
        result = func(*args, **kwargs)
        without_finally.append("after")
        return result
    return wrapper

@announce
def risky():
    raise ValueError("the payment gateway is down")

try:
    risky()
except ValueError as error:
    caught = str(error)

print("recorded:", without_finally)
print("caught:  ", caught)
```

`['before']`. The wrapper started and never finished. Note that the
exception itself is fine: it reached the caller intact, which is exactly
what should happen. The damage is that the decorator's own work was
abandoned halfway.

`try`/`finally` is how you say "run this whichever way the call goes".
The `finally` block runs when the call returns and when it raises.

```{cell-insert}
:id: insert-finally
:path: {{ notebook }}
:tags: [finally-fix]
:run: true
with_finally = []

def announce(func):
    def wrapper(*args, **kwargs):
        with_finally.append("before")
        try:
            result = func(*args, **kwargs)
        finally:
            with_finally.append("after")
        return result
    return wrapper

@announce
def risky():
    raise ValueError("the payment gateway is down")

try:
    risky()
except ValueError as error:
    caught = str(error)

print("recorded:", with_finally)
print("caught:  ", caught)
```

`['before', 'after']`, and the `ValueError` still arrives. `finally` does
not catch anything and does not make the error go away: it only
guarantees the block runs on the way past. That is the difference between
cleaning up and swallowing.

```{verify}
:id: finally-runs
:label: The after step is skipped without finally and runs with it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed finally-fix
without_finally == ["before"] and with_finally == ["before", "after"]
```

So far "after" has meant one thing, the work that follows the call. It
is really three different moments, and a wrapper that treats them as one
cannot say whether the call worked:

- `except` runs only when the call raised. Re-raise at the end of it,
  or you have swallowed the error.

- `else` runs only when the call returned.

- `finally` runs either way, last.

```{cell-insert}
:id: insert-branches
:path: {{ notebook }}
:tags: [branches]
:run: true
outcomes = []

def announce(func):
    def wrapper(*args, **kwargs):
        try:
            result = func(*args, **kwargs)
        except Exception:
            outcomes.append("failed")
            raise
        else:
            outcomes.append("succeeded")
            return result
        finally:
            outcomes.append("done")
    return wrapper

@announce
def works():
    return "fine"

@announce
def breaks():
    raise ValueError("nope")

works()

try:
    breaks()
except ValueError:
    pass

print("outcomes:", outcomes)
```

`['succeeded', 'done', 'failed', 'done']`. The successful call recorded
`succeeded` then `done`; the failing one recorded `failed` then `done`.
Note that `done` is appended after the `return` in the `else` branch:
`finally` always gets its turn, even on the way out of a `return`.

Your `@timer` from earlier has the same bug. It reports nothing when the
call raises, which is the wrong way round: a call that failed after four
seconds is the one most worth knowing about. Move the measurement into a
`finally` and it reports either way.

```{cell-insert}
:id: insert-timer-fixed
:path: {{ notebook }}
:tags: [timer-fixed]
:run: true
timings = []

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            elapsed = time.perf_counter() - start
            timings.append(elapsed)
            print(f"{func.__name__} took {elapsed:.3f}s")
    return wrapper

@timer
def slow_failure():
    time.sleep(0.05)
    raise RuntimeError("gave up")

try:
    slow_failure()
except RuntimeError as error:
    failed = str(error)

print("caught:  ", failed)
print("timings: ", len(timings))
```

The timing is reported even though the call failed, and the
`RuntimeError` still reaches the caller. `return func(...)` sits inside
the `try`, so the `finally` runs before the value is handed back.

```{verify}
:id: branches-and-timer
:label: The three branches ran in order and the timer survived a failure
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed timer-fixed
outcomes == ["succeeded", "done", "failed", "done"] and failed == "gave up" and len(timings) == 1 and timings[0] >= 0.04
```

```{hint}
:title: When the simple shape is still fine
When the work after the call only makes sense if the call succeeded,
put it after the call and leave it there. Caching is the clear case: a
result that was never produced must not be stored, so `@functools.cache`
is right to skip its bookkeeping when the function raises. Reach for
`finally` when the work is cleanup or measurement, which has to happen
either way.
```
