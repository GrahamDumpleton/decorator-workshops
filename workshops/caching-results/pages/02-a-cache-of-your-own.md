---
title: A cache of your own
requires: [verify:memoize-works]
---

# A cache of your own

The whole idea fits in a few lines. Keep a dictionary. Look in it before
calling. Put the answer in it afterwards.

The dictionary lives in the decorator's scope, so each decorated
function gets its own, and it stays alive because the wrapper closes
over it, which is workshop three doing useful work.

```{cell-insert}
:id: insert-memoize
:path: {{ notebook }}
:tags: [memoize]
:run: true
def memoize(func):
    cache = {}

    @functools.wraps(func)
    def wrapper(*args):
        if args in cache:
            return cache[args]
        result = func(*args)
        cache[args] = result
        return result

    wrapper.cache = cache
    return wrapper

runs["count"] = 0

@memoize
def fib(n):
    runs["count"] += 1
    return n if n < 2 else fib(n - 1) + fib(n - 2)

print("fib(20) =", fib(20))
print("body ran:", runs["count"], "times")
print("cached values:", len(fib.cache))
```

Twenty-one runs instead of nearly twenty-two thousand, from four lines
of caching.

The reason it collapses so far is worth noticing: `fib` calls itself by
name, and the name now points at the wrapper, so the recursion goes
through the cache too. Every value is computed once and then found.

`args` is the key, and using the tuple directly is the shortest thing
that works. The next page is about how much it does not work.

```{verify}
:id: memoize-works
:label: The cache cut the work down to one run per value
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed memoize
fib(20) == 6765 and runs["count"] == 21 and len(fib.cache) == 21
```

```{hint}
:title: Why the count is exactly 21
One run for each of `fib(0)` through `fib(20)`. That is the floor: every
distinct question is asked of the real function exactly once, and
everything after is a lookup.
```
