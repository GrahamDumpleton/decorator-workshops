---
title: What you know now
requires: [quiz:why-it-timed-nothing]
---

# What you know now

Calling an async function builds a coroutine and runs nothing. Every
decorator you had written assumed the opposite, so on an `async def` an
ordinary wrapper times the construction of a coroutine, retries a thing
that has not failed yet, and returns an object where the caller expected
a value, all without raising.

The fix is that the wrapper becomes a coroutine function too:

```python
def decorator(func):
    @functools.wraps(func)
    async def wrapper(*args, **kwargs):
        # before
        result = await func(*args, **kwargs)
        # after
        return result
    return wrapper
```

One decorator can serve both kinds by asking
`inspect.iscoroutinefunction(func)` once, at decoration time, and
returning whichever wrapper fits. Not `asyncio.iscoroutinefunction`,
which is deprecated and due for removal.

And anything that waits must `await asyncio.sleep`. Synchronous work
inside a coroutine, which on CPython includes `time.sleep`, blocks the
whole event loop, so every other task in the process stops too,
silently.

```{quiz}
:id: why-it-timed-nothing
:title: Why it timed nothing
:shuffle: true
question: "Why did the ordinary `@timer` report microseconds for a function that sleeps for 50ms?"
options:
  - text: "Because calling an async function only builds a coroutine, and that is all the wrapper timed."
    correct: true
  - text: "Because `time.perf_counter` does not work correctly inside an event loop."
    explanation: "It works fine. The two readings were accurate; they were just taken either side of something that does no work."
  - text: "Because the sleep was skipped, as nothing awaited the coroutine."
    explanation: "True but not the reason for the number. Even when the coroutine was awaited afterwards, the timing had already been printed, because the wrapper finished before the work began."
  - text: "Because the decorator ran before the event loop started."
    explanation: "The decorator runs at definition time either way. The problem is what the wrapper does on each call, not when the decorator itself ran."
explanation: "`func(*args, **kwargs)` on an async function returns immediately with a coroutine. The wrapper timed that construction, which genuinely takes microseconds, and returned the coroutine untouched."
```

## That is the collection

Fourteen workshops ago a decorator was a line with an `@` in front of it
that did something you could not quite see.

You have used decorators from the standard library, written your own by
hand and then with `@`, found the closure that lets a wrapper remember,
given decorators arguments, kept the wrapped function's identity,
stacked them and reasoned about the order, put them on methods and
watched them break, written them as classes, taken apart the binding
that made them break, decorated classes as well as functions, and built
four worth keeping: a cache, a registry, a retry, and one that works on
coroutines.

Where to go next, if you want to:

- **`functools`** repays a proper read now, since you know what
  `wraps`, `cache` and `lru_cache` are doing.

- **`wrapt`** exists because writing one decorator that correctly
  handles functions, methods, classmethods, staticmethods and
  coroutines is genuinely hard, as the last page hinted.

Press Finish below to end the workshop.
