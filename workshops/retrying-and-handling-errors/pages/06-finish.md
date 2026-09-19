---
title: What you know now
requires: [quiz:the-missing-raise]
---

# What you know now

Four things a decorator can do with a failure, and the judgement each
needs:

- **Log it**, then `raise` so it continues. The bare `raise` is not
  optional.

- **Translate it**, with `from error` so the cause is kept and the
  traceback shows both.

- **Retry it**, but only the exceptions that might behave differently
  next time, with a delay that grows.

- **Suppress it**, rarely, and with suspicion.

And you saw the stacking order decide something real: logging above
retrying records failed operations, logging below records failed
attempts, one line against three for the same failure.

```{quiz}
:id: the-missing-raise
:title: The missing raise
:shuffle: true
question: "What happens if `@log_exceptions` logs the failure but leaves out the final `raise`?"
options:
  - text: "The exception is swallowed, the function returns None, and the caller carries on as if it had succeeded."
    correct: true
  - text: "The exception is re-raised anyway, because it was never caught."
    explanation: "It was caught: that is what `except Exception` did. An except block that neither raises nor returns simply finishes, and the wrapper falls off the end."
  - text: "The function returns whatever it had computed before failing."
    explanation: "It computed nothing that the wrapper can see. `result = func(...)` never completed, so there is no value, and the wrapper returns None by default."
  - text: "Python warns about an exception that was caught and not handled."
    explanation: "There is no such warning. Catching an exception and doing nothing is legal and silent, which is exactly what makes this bug so expensive."
explanation: "The failure is logged and then discarded, the wrapper returns None, and the caller treats that as a result. The bug surfaces much later and somewhere else."
```

## Where this goes next

Everything you have written assumes calling the function does the work.
Put any of these decorators on an `async def` and that stops being true:
calling it gives you a coroutine and does nothing at all, so the timer
times nothing, the retry retries nothing, and the wrapper hands back an
object the caller was not expecting.

The last workshop is about making decorators work with `async`, and
about spotting the failure, which is quiet rather than loud.

**Decorating async functions** is next.

Press Finish below to move on.
