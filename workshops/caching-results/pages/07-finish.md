---
title: What you know now
requires: [quiz:which-cache]
---

# What you know now

A cache is a dictionary, a lookup before the call and a store after it.
That is all `@functools.cache` was doing in the first workshop.

Writing one taught you where the difficulty actually is, and it is not
the caching. It is the key:

- Keyed on `args` alone, keyword calls are refused and unhashable
  arguments raise.

- Keyed on `args` and `kwargs` naively, the same call written two ways
  gets two entries and never hits.

- Keyed on bound arguments through `inspect.signature`, every spelling
  of a call agrees, at the cost of binding on every call.

The standard library takes the first option deliberately and is right
to: it is the fast one, and the mismatch is easy to avoid by calling
consistently.

You also know what it costs. `lru_cache(maxsize=n)` evicts and can be
too small to help at all, which `cache_info()` tells you. `cache` never
evicts, so it grows for ever on a function whose arguments keep
changing. And on a method it holds every instance alive, which is a leak
you cannot see until you go looking for it.

```{quiz}
:id: which-cache
:title: Choosing a cache
:shuffle: true
question: "Which of these is the poorest candidate for `@functools.cache`?"
options:
  - text: "A method that looks up a user's permissions from `self`."
    correct: true
  - text: "A function parsing a configuration file given its path."
    explanation: "A good candidate: few distinct paths, an expensive result, and the same answer each time."
  - text: "A recursive function over small integers."
    explanation: "The ideal case, as fib showed: a small key space and enormous reuse."
  - text: "A function converting a currency code to a symbol."
    explanation: "A good candidate: the key space is small and fixed, so the cache stops growing almost immediately."
explanation: "Caching a method caches the instance as its first argument, so every object it is called on is kept alive for the lifetime of the process, and a permissions result is exactly the kind of thing that should not be remembered indefinitely anyway."
```

## Where this goes next

Every decorator so far has wrapped a function in another function. The
next one does not wrap anything: it takes your function, writes it down
somewhere, and hands it straight back unchanged.

That sounds useless and is the shape you have most likely already used,
in Flask, Click or pytest.

**Registering functions** is next.

Press Finish below to move on.
