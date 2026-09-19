---
title: What it costs
requires: [verify:the-costs]
---

# What it costs

A cache trades memory for time, and the trade is easy to make without
noticing.

`@functools.cache` has no limit, so it keeps an entry for every distinct
set of arguments it is ever called with, for the lifetime of the
process.

```{cell-insert}
:id: insert-growth
:path: {{ notebook }}
:tags: [growth]
:run: true
@functools.cache
def square(n):
    return n * n

for n in range(500):
    square(n)

print(square.cache_info())
```

Five hundred calls, five hundred entries, no hits, and `maxsize=None`
means nothing will ever be evicted. On a function called with a handful
of repeated arguments that is ideal. On one called with a user id, a
timestamp or a search term, it is a memory leak with good manners: every
call is a new key, the cache only grows, and nothing looks wrong until
the process runs out of room days later.

There is a second cost, and it is the one the documentation warns about
because it is genuinely surprising.

```{cell-insert}
:id: insert-leak
:path: {{ notebook }}
:tags: [leak]
:run: true
import gc
import weakref

class Report:
    def __init__(self, name):
        self.name = name

    @functools.cache
    def total(self):
        return len(self.name)

report = Report("quarterly")
report.total()

ref = weakref.ref(report)
del report
gc.collect()

alive = ref() is not None
print("deleted object still alive?", alive)

Report.total.cache_clear()
gc.collect()
print("alive after clearing the cache?", ref() is not None)
```

Caching a method caches its arguments, and the first argument of a
method is the instance. So the cache holds a reference to every object
any of its methods was called on, and none of them can ever be
collected. `del report` did nothing at all; only clearing the cache let
it go.

That makes `@functools.cache` on a method a memory leak by
construction, on a per-class cache shared by every instance. The
standard library documents this and does not prevent it. Cache a plain
function, or a method whose result depends only on its explicit
arguments and which you have thought about carefully.

```{verify}
:id: the-costs
:label: The cache grew without limit and held a deleted object alive
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed leak
square.cache_info().currsize == 500 and square.cache_info().maxsize is None and alive is True and ref() is None
```
