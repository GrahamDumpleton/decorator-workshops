---
title: Fixing the key
requires: [verify:normalised]
---

# Fixing the key

The fix is to stop keying on how the call was written and start keying
on what it means. `inspect.signature` knows the function's parameters,
and `bind` works out which argument went where, whatever style the
caller used.

```{cell-insert}
:id: insert-normalised
:path: {{ notebook }}
:tags: [normalised]
:run: true
def memoize(func):
    cache = {}
    sig = inspect.signature(func)

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        bound = sig.bind(*args, **kwargs)
        bound.apply_defaults()
        key = tuple(bound.arguments.items())

        if key in cache:
            return ("hit", cache[key])

        cache[key] = func(*args, **kwargs)
        return ("miss", cache[key])

    wrapper.cache = cache
    return wrapper

@memoize
def box(width, height=2):
    return width * height

print(box(3))
print(box(width=3))
print(box(3, 2))
print("entries in the cache:", len(box.cache))
```

One miss and two hits, for three calls written three different ways, and
one entry in the cache.

`bind` matched each argument to its parameter, and `apply_defaults`
filled in `height=2` for the call that left it out, so `box(3)` and
`box(3, 2)` are recognised as the same question. The key is built from
the bound arguments, which describe the call rather than its spelling.

The hit and miss labels are only there so you can see what happened; a
real cache returns the value.

What this does not fix is the unhashable argument. A list is still a
list after binding, and still cannot be a dictionary key. There is no
general answer to that, which is why the standard library does not
attempt one: a cache keyed on mutable arguments would have to decide
what to do when the caller changes them afterwards, and any answer is
wrong for somebody.

```{verify}
:id: normalised
:label: Three spellings of the same call share one cache entry
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed normalised
box(3)[0] == "hit" and box(width=3)[0] == "hit" and len(box.cache) == 1
```

```{hint}
:title: The cost of being correct
`inspect.signature` is computed once at decoration, which is free, but
`bind` runs on every call and is not. For a function that takes
microseconds, binding can cost more than the work you are avoiding. The
standard library's cache keys on the raw arguments for exactly this
reason and accepts the `f(1)` versus `f(x=1)` miss as the price.
```
