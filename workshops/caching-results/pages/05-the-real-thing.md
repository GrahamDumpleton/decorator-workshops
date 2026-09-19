---
title: The real thing
requires: [verify:lru-behaviour]
---

# The real thing

You would not ship any of the above. `functools.lru_cache` is the one to
use, and now you know what it is doing.

The difference that matters is `maxsize`. Your cache grew for ever;
this one keeps a fixed number of entries and discards the least recently
used to make room.

```{cell-insert}
:id: insert-lru
:path: {{ notebook }}
:tags: [lru]
:run: true
@functools.lru_cache(maxsize=2)
def cube(n):
    return n ** 3

for n in [1, 2, 3, 1]:
    cube(n)

print("after 1, 2, 3, 1 with room for two:", cube.cache_info())
```

`hits=0, misses=4`. Four calls, no hits at all, even though `1` was
asked for twice.

Follow the evictions: `1` and `2` fill the cache, `3` arrives and pushes
out `1` as the least recently used, and the second `1` is therefore a
miss. A cache too small for the pattern of calls does the bookkeeping
and provides none of the benefit, which is why `cache_info()` exists.
`hits` staying near zero in production is the signal to raise `maxsize`
or stop caching.

`cache_clear()` empties it, which is mostly useful in tests, where a
cache surviving between cases is a fine way to make them pass in one
order and fail in another.

```{cell-insert}
:id: insert-clear
:path: {{ notebook }}
:tags: [clear]
:run: true
before = cube.cache_info()
cube.cache_clear()
after = cube.cache_info()

print("before:", before)
print("after :", after)
```

`functools.cache` is the same machinery with no limit at all. It is
shorthand for `lru_cache(maxsize=None)`, which is faster because there
is no eviction bookkeeping to do, and which never gives memory back.

```{verify}
:id: lru-behaviour
:label: The small cache evicted, and clearing emptied it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed clear
before.misses == 4 and before.currsize == 2 and after.currsize == 0 and after.hits == 0
```
