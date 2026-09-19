---
title: A wrapper that awaits
requires: [verify:async-timer]
---

# A wrapper that awaits

If the work happens on `await`, the wrapper has to be the thing that
awaits. Which means the wrapper itself must be an `async def`.

Two changes, both small: `async` in front of `def wrapper`, and `await`
in front of the call.

```{cell-insert}
:id: insert-async-timer
:path: {{ notebook }}
:tags: [async-timer]
:run: true
timings = []

def async_timer(func):
    @functools.wraps(func)
    async def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = await func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        timings.append(elapsed)
        print(f"{func.__name__} took {elapsed:.3f}s")
        return result
    return wrapper

@async_timer
async def fetch_properly(item):
    await asyncio.sleep(0.05)
    return f"got {item}"

proper = await fetch_properly("hat")

print("value:", proper)
```

Fifty milliseconds, which is the truth, and a string rather than a
coroutine.

What makes this work is that `wrapper` is now a coroutine function too,
so `fetch_properly("hat")` builds a coroutine of the *wrapper*, and
awaiting it runs the wrapper, which awaits the real function. The
decorated function is still awaitable from the caller's point of view,
which is exactly what a decorator should preserve: it has not changed
how the function is used.

The shape is otherwise identical to every decorator in this collection.
The timing lines sit either side of the call as they always have; the
call in the middle is now awaited.

```{verify}
:id: async-timer
:label: The async wrapper measured the real work
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed async-timer
proper == "got hat" and len(timings) == 1 and timings[0] >= 0.04
```

```{hint}
:title: This one now only works on async functions
`await func(...)` requires something awaitable, so `@async_timer` on a
plain function fails. You now have two decorators that do the same job
for two kinds of function, which is the problem the next page solves.
```
