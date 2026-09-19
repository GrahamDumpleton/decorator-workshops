---
title: The quiet failure
requires: [verify:coroutine-returned]
---

# The quiet failure

Here is the `@timer` from workshop two, unchanged, on an async function.
It raises nothing and prints a number, which is what makes it dangerous.

```{cell-insert}
:id: insert-quiet
:path: {{ notebook }}
:tags: [quiet]
:run: true
def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__} took {elapsed:.6f}s")
        return result
    return wrapper

@timer
async def fetch_timed(item):
    await asyncio.sleep(0.05)
    return f"got {item}"

returned = fetch_timed("hat")

print("returned a:", type(returned).__name__)
returned.close()
```

A few millionths of a second, for something that sleeps for fifty
thousand. And the thing handed back is a `coroutine`, not a string.

The wrapper did exactly what it was told. `func(*args, **kwargs)` built
a coroutine and returned immediately, the two clock readings sit either
side of that construction, and the timing is real: building a coroutine
really is that fast. It is the question that is wrong.

`returned.close()` is there for tidiness. A coroutine that is created
and never awaited is work nobody did, and Python says so with a
`RuntimeWarning` when it is eventually collected. Closing it says the
decision was deliberate.

Now watch the other half of the damage. The caller can still get the
value, but only by knowing to await what came back.

```{cell-insert}
:id: insert-awaited
:path: {{ notebook }}
:tags: [awaited]
:run: true
coro = fetch_timed("coat")
value = await coro

print("after awaiting:", value)
```

The timing printed before the work happened, because the wrapper had
already finished by then. A decorator meant to report how slow something
is has reported a number unrelated to it, in the right units, on every
call, with no error anywhere.

```{verify}
:id: coroutine-returned
:label: The sync wrapper returned a coroutine and timed nothing
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed awaited
type(returned).__name__ == "coroutine" and value == "got coat"
```

```{hint}
:title: How this reaches production
It does not fail a test that only checks the return value, because
`await`ing the coroutine still gives the right answer. It fails the
dashboard: a latency graph that has been flat and implausibly fast for
months, which nobody questions because fast is what you were hoping for.
```
