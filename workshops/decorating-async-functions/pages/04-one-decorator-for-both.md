---
title: One decorator for both
requires: [verify:universal]
---

# One decorator for both

Maintaining `@timer` and `@async_timer` side by side is the kind of
duplication that goes stale: a fix lands in one and not the other.

A decorator can ask what it has been given and return the appropriate
wrapper. The question is answered by `inspect.iscoroutinefunction`, and
it is answered once, at decoration time, not on every call.

```{cell-insert}
:id: insert-universal
:path: {{ notebook }}
:tags: [universal]
:run: true
seen = []

def universal(func):
    if inspect.iscoroutinefunction(func):

        @functools.wraps(func)
        async def async_wrapper(*args, **kwargs):
            seen.append((func.__name__, "async"))
            return await func(*args, **kwargs)

        return async_wrapper

    @functools.wraps(func)
    def sync_wrapper(*args, **kwargs):
        seen.append((func.__name__, "sync"))
        return func(*args, **kwargs)

    return sync_wrapper

@universal
def add(a, b):
    return a + b

@universal
async def fetch_both(item):
    await asyncio.sleep(0.02)
    return f"got {item}"

sync_value = add(2, 3)
async_value = await fetch_both("hat")

print(sync_value, "|", async_value)
print(seen)
```

One decorator, two functions, both working the way their callers expect:
`add(2, 3)` returns 5 directly, and `fetch_both("hat")` is awaited.

Two details that matter more than they look.

**Use `inspect.iscoroutinefunction`, not the `asyncio` one.**
`asyncio.iscoroutinefunction` does the same job and is deprecated: it
warns on Python 3.14 and is scheduled for removal in 3.16, with the
interpreter itself pointing at the `inspect` version. Plenty of existing
code and advice still uses it.

**The test happens once.** `universal` runs at decoration, picks a
wrapper and returns it, so there is no branch on the hot path. Testing
inside the wrapper would cost something on every single call to answer a
question whose answer cannot change.

```{verify}
:id: universal
:label: One decorator handled both a sync and an async function
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed universal
sync_value == 5 and async_value == "got hat" and seen == [("add", "sync"), ("fetch_both", "async")]
```

```{hint}
:title: Where this stops being pleasant
Two kinds is manageable. Add generators, async generators, methods and
classmethods and the branching multiplies, and each branch needs the
same care about `wraps`, argument forwarding and exceptions. That is the
point at which people reach for `wrapt`, which handles the dispatch so a
decorator can be written once.
```
