---
title: One line changes everything
requires: [verify:cache-is-working]
---

# One line changes everything

`lookup_price` is slow every time, even when it is asked the same
question twice. Time two identical calls and see.

```{cell-insert}
:id: insert-slow-twice
:path: {{ notebook }}
:tags: [slow-twice]
:run: true
start = time.perf_counter()
lookup_price("widget")
first = time.perf_counter() - start

start = time.perf_counter()
lookup_price("widget")
second = time.perf_counter() - start

print(f"first  call: {first:.3f}s")
print(f"second call: {second:.3f}s")
```

Both calls take about the same time. The second one did the same work
as the first to reach an answer it had already found once.

Now define the same function again, with one line added above it, and
time it the same way. The body is untouched.

```{cell-insert}
:id: insert-cached
:path: {{ notebook }}
:tags: [cached]
:run: true
import functools

@functools.cache
def lookup_price(item):
    time.sleep(0.05)
    return len(item) * 10

start = time.perf_counter()
lookup_price("widget")
first = time.perf_counter() - start

start = time.perf_counter()
lookup_price("widget")
second = time.perf_counter() - start

print(f"first  call: {first:.3f}s")
print(f"second call: {second:.6f}s")
```

The first call is as slow as ever. The second is thousands of times
faster, because it never ran the function at all: the answer was
remembered from the first call and handed straight back.

Nothing inside `lookup_price` knows about any of this. It still sleeps
and still multiplies. Something is now sitting in front of it, and that
something is what `@functools.cache` put there.

Ask it what it has been doing.

```{cell-insert}
:id: insert-cache-info
:path: {{ notebook }}
:tags: [cache-info]
:run: true
lookup_price.cache_info()
```

One miss, for the call that had to do the work, and one hit, for the
call that did not. `cache_info` is not a method you wrote on
`lookup_price`, and the original function never had it.

```{verify}
:id: cache-is-working
:label: The second call was answered from the cache
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed cache-info
lookup_price.cache_info().hits >= 1 and second < 0.01
```

```{hint}
:title: If the check fails
Run the cell tagged `cached` above, then the `cache_info` cell. If the
second timing is not far smaller than the first, the two calls asked
different questions: both must pass the same argument, `"widget"`.
```
