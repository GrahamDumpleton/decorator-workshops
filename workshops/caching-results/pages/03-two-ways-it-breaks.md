---
title: Two ways it breaks
requires: [verify:both-breakages]
---

# Two ways it breaks

`fib` takes one small integer, which is the easy case. Give the same
decorator a more ordinary function and two problems appear at once.

```{cell-insert}
:id: insert-breaks
:path: {{ notebook }}
:tags: [breaks]
:run: true
@memoize
def area(width, height):
    return width * height

area(2, 3)
print("cached keys after area(2, 3):", list(area.cache))

try:
    area(width=2, height=3)
    keyword = "no error"
except TypeError as error:
    keyword = str(error)

print("same call by keyword:", keyword)

try:
    area([1, 2], 3)
    unhashable = "no error"
except TypeError as error:
    unhashable = str(error)

print("with a list argument:", unhashable)
```

**Keyword arguments are refused outright.** The wrapper was written
`def wrapper(*args)`, which accepts no keyword arguments at all, so
`area(width=2, height=3)` never reaches the cache or the function. This
is worth more attention than it looks, because it is a decorator that
works perfectly until someone calls the function in the other legal way.
Adding `**kwargs` to the wrapper would fix the error and leave a subtler
bug behind: `area(2, 3)` and `area(width=2, height=3)` are the same call
and would get different keys, so the cache would miss every time and
quietly grow two entries for one answer.

**Unhashable arguments raise.** Dictionary keys must be hashable, and a
tuple containing a list is not, so caching a function that takes a list
fails as soon as anyone passes one.

Both come from the same shortcut: the key was the arguments as they
happened to be written, rather than what the call actually means.

```{verify}
:id: both-breakages
:label: Keyword and unhashable arguments both break the naive cache
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed breaks
"unexpected keyword argument" in keyword and "unhashable" in unhashable
```
