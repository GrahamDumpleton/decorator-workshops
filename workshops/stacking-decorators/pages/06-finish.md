---
title: What you know now
requires: [quiz:two-orders]
---

# What you know now

A stack of decorators is nested calls, nothing more:

```python
@bold
@italic
def greeting():
    ...

# is
greeting = bold(italic(greeting))
```

From that one fact everything else follows. The decorator nearest the
`def` is applied first and ends up innermost. The one furthest away is
applied last and ends up outermost, which makes it the first to run on
every call. Applied bottom to top, run top to bottom.

You saw the order decide an output, with `<b>` and `<i>`, and then
decide a number, with a counter above and below a cache, where both
answers were correct and meant different things. And you followed a
stack back to the original through `__wrapped__`, and watched one
careless decorator cut the thread for everything above it.

```{quiz}
:id: two-orders
:title: Which runs first
:shuffle: true
question: "With `@authenticate` above `@cache` above `def fetch()`, which wrapper does a call reach first?"
options:
  - text: "authenticate, because it is outermost."
    correct: true
  - text: "cache, because it was applied first."
    explanation: "It was applied first, which is exactly why it is innermost. Being applied early puts a decorator closer to the function, not closer to the caller."
  - text: "fetch, because the function always runs before its decorators."
    explanation: "The name fetch points at the outermost wrapper, so a call enters there. The original function runs in the middle, once every wrapper above it has had its turn on the way in."
  - text: "It depends on which one uses functools.wraps."
    explanation: "wraps affects what the function reports about itself, never the order anything runs in."
explanation: "Applied bottom to top, run top to bottom. authenticate is furthest from the def, so it is applied last, ends up outermost, and is the first thing a call meets. Which is what you want: check the credentials before consulting the cache."
```

## Where this goes next

Every decorator so far has gone on a plain function. Put one on a method
inside a class and some of them keep working and some fall over with a
`TypeError` about a missing `self`, which is the single most common
surprise people meet with decorators.

**Decorating methods** is next.

Press Finish below to move on.
