---
title: The @ is not magic
requires: [verify:same-by-hand]
---

# The @ is not magic

`@functools.cache` looks like new syntax, something the interpreter
treats specially. It is not. It is shorthand for one ordinary line of
Python that you can write yourself.

`functools.cache` is just a function. Call it, pass it a function, and
it hands back a different function. Do that by hand, with no `@`
anywhere.

```{cell-insert}
:id: insert-by-hand
:path: {{ notebook }}
:tags: [by-hand]
:run: true
def expensive(n):
    time.sleep(0.05)
    return n * 2

cheap = functools.cache(expensive)

start = time.perf_counter()
cheap(5)
first = time.perf_counter() - start

start = time.perf_counter()
cheap(5)
second = time.perf_counter() - start

print(f"first  call: {first:.3f}s")
print(f"second call: {second:.6f}s")
print("same object?", cheap is expensive)
```

The same caching, with no `@`. `cheap` is not `expensive`: it is a new
object that `functools.cache` built, holding the original inside it and
deciding when to bother calling it.

So these two are the same thing written twice:

```python
@functools.cache
def lookup_price(item):
    ...

# and

def lookup_price(item):
    ...
lookup_price = functools.cache(lookup_price)
```

That is the whole rule. `@something` above a `def` means: define the
function, hand it to `something`, and bind the name to whatever comes
back. The name you defined ends up pointing at the replacement.

It explains what you saw on the last two pages.
`@functools.cache` gave back an object with a `cache_info` method,
which is why `lookup_price.cache_info()` worked. `@property` gave back
an object that runs a method when read and refuses to be assigned to.
`@dataclasses.dataclass` was handed a class rather than a function, and
gave back that same class with methods added.

```{verify}
:id: same-by-hand
:label: Caching by hand works, and gives back a new object
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed by-hand
second < 0.01 and cheap is not expensive
```

```{hint}
:title: Why bother with the @ then
Because the `@` says it at the top, where the function is defined,
instead of on a line further down that is easy to miss. When you read
`@functools.cache` above a function you know immediately that the
function is not quite what it appears to be.
```
