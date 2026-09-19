---
title: Waiting without blocking
requires: [verify:blocking]
---

# Waiting without blocking

Any decorator that waits has to wait the async way. A retry is the
clearest case, because waiting is the whole point of the delay.

```{cell-insert}
:id: insert-async-retry
:path: {{ notebook }}
:tags: [async-retry]
:run: true
def async_retry(attempts=3, delay=0.01):
    def decorator(func):
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            for attempt in range(1, attempts + 1):
                try:
                    return await func(*args, **kwargs)
                except ConnectionError:
                    if attempt == attempts:
                        raise
                    await asyncio.sleep(delay * attempt)
        return wrapper
    return decorator

calls = {"n": 0}

@async_retry(attempts=3)
async def flaky():
    calls["n"] += 1
    if calls["n"] < 3:
        raise ConnectionError("down")
    return "connected"

recovered = await flaky()

print("result:", recovered, "| calls:", calls["n"])
```

The same retry you wrote before, with `await asyncio.sleep` in place of
`time.sleep`. That substitution is the one thing to get right, and here
is why it matters.

Two tasks running together, waiting the async way:

```{cell-insert}
:id: insert-interleaved
:path: {{ notebook }}
:tags: [interleaved]
:run: true
interleaved = []

async def polite(name):
    for _ in range(3):
        await asyncio.sleep(0.01)
        interleaved.append(name)

await asyncio.gather(polite("a"), polite("b"))

print(interleaved)
```

`['a', 'b', 'a', 'b', 'a', 'b']`. Each `await` is a moment where the
task says it has nothing to do, and the loop runs the other one.

The same two tasks again, but this time each one keeps the processor
busy for its ten milliseconds instead of awaiting:

```{cell-insert}
:id: insert-blocked
:path: {{ notebook }}
:tags: [blocked]
:run: true
blocked = []

async def rude(name):
    for _ in range(3):
        end = time.perf_counter() + 0.01
        while time.perf_counter() < end:
            pass
        blocked.append(name)

await asyncio.gather(rude("a"), rude("b"))

print(blocked)
```

`['a', 'a', 'a', 'b', 'b', 'b']`. No interleaving at all. `rude` never
awaits anything, so it never gives the loop a chance to run anything
else; it runs to completion and only then does the second task start.

Nothing is concurrent any more, and nothing reports an error. That is
what `async def` buys you and what it does not: it lets a coroutine
step aside, and it cannot make one do so. Synchronous work inside an
async wrapper stops the entire event loop, not just the task it is in,
so every other request the process is serving waits too.

On CPython `time.sleep` is exactly this kind of work, which is why a
retry decorator with a one second `time.sleep` backoff is an outage on
a busy server. In this notebook it is not: the Pyodide kernel's
`time.sleep` returns to the browser's event loop while it waits, so
sleeping coroutines here interleave like the polite ones above. The
rule survives the difference. Await what you can, and assume anything
you do not await is holding the loop.

```{verify}
:id: blocking
:label: The async wait interleaved and the blocking wait did not
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed blocked
recovered == "connected" and interleaved == ["a", "b", "a", "b", "a", "b"] and blocked == ["a", "a", "a", "b", "b", "b"]
```

```{hint}
:title: When the work really is blocking
Sometimes the thing you have to call is synchronous and slow, a library
with no async version. The answer is not to call it directly in a
coroutine but to hand it to a thread, with
`await asyncio.to_thread(func, *args)`, which returns control to the
loop while the thread works.
```
