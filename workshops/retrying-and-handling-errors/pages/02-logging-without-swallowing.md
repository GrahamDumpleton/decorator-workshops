---
title: Logging without swallowing
requires: [verify:logged-and-raised]
---

# Logging without swallowing

The first and most useful of the four. Record that something failed,
then let the failure continue on its way.

The whole decorator is a `try`/`except` with one line in it, and the
important line is the last one.

```{cell-insert}
:id: insert-log
:path: {{ notebook }}
:tags: [log]
:run: true
records.clear()

def log_exceptions(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception:
            logger.exception("%s failed", func.__name__)
            raise
    return wrapper

@log_exceptions
def explode():
    raise ValueError("boom")

try:
    explode()
    outcome = "no error"
except ValueError as error:
    outcome = str(error)

print("reached the caller:", outcome)
print("logged:", records)
```

Both things happened: the failure was recorded, and the caller still got
its `ValueError`.

That bare `raise` is the point of the page. It re-raises the exception
currently being handled, with its original traceback intact, so the log
gains a line and nothing else changes. Delete it and you have written
the single most damaging decorator there is: every failure is quietly
logged and then discarded, the function returns `None`, and the caller
proceeds as though the work succeeded. The bug surfaces much later, in a
different part of the system, as a `None` where a value should be.

Two details worth copying:

- `logger.exception` rather than `logger.error`. It is the same thing
  with the traceback attached, and it is only valid inside an `except`
  block, which is exactly where you are.

- `except Exception`, not `except BaseException` and not a bare
  `except:`. `KeyboardInterrupt` and `SystemExit` are not errors your
  code should be logging and re-raising, and catching them makes a
  program that will not stop when asked.

```{verify}
:id: logged-and-raised
:label: The failure was logged and still reached the caller
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed log
outcome == "boom" and records == ["explode failed"]
```
