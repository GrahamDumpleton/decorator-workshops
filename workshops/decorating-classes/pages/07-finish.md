---
title: What you know now
requires: [quiz:the-hash-trap]
---

# What you know now

A decorator on a class is the rule you started with, unchanged. The
class statement builds the class, the decorator receives it, and the
name is bound to whatever comes back.

```python
def decorator(cls):
    cls.some_method = ...      # change it
    return cls                 # and hand it back
```

Returning the same object is the normal case. The class is mutable, so
a decorator can add methods, replace existing ones, or record the class
somewhere, and every instance made afterwards has the result.

Three things worth carrying away:

- Adding a method from outside works on every instance, including ones
  created by code that never heard of the decorator.

- Replacing behaviour needs care about re-entering yourself.
  `object.__setattr__` is how `frozen` sets an attribute without going
  back through the `__setattr__` it just installed.

- Protections that the interpreter applies to a class body do not apply
  to a decorator. Adding `__eq__` afterwards leaves `__hash__` alone,
  and equal objects then fail to find each other in sets and
  dictionaries.

And `@dataclass` is not a language feature. It is a function that takes
a class, reads its annotations, attaches methods and returns it, which
is what you have been doing by hand.

```{quiz}
:id: the-hash-trap
:title: Equal objects in a set
:shuffle: true
question: "A class decorator assigns `cls.__eq__`. Two instances compare equal, but a set containing both has two entries. Why?"
options:
  - text: "Because a set orders its contents with `__lt__`, which the decorator defined inconsistently with `__eq__`."
    explanation: "Sets are unordered and do not use `__lt__` at all. The lookup is by hash first, then equality."
  - text: "Because assigning `__eq__` after the class exists leaves the default identity-based `__hash__` in place, so equal objects hash differently."
    correct: true
  - text: "Because `__eq__` assigned as a lambda is not recognised by the set machinery."
    explanation: "A lambda is a perfectly ordinary function here. Defining the same lambda in the class body would behave differently, but because of when it is assigned, not what it is."
  - text: "Because sets compare their members by identity and ignore `__eq__` entirely."
    explanation: "Sets do use `__eq__`, but only after the hash has brought two objects into the same bucket. With different hashes they are never compared."
explanation: "Python sets `__hash__` to `None` when `__eq__` appears in a class body, which turns the mistake into a `TypeError`. A decorator assigns `__eq__` after the body has been compiled, so that never happens and the class keeps a hash inconsistent with its equality."
```

## Where this goes next

That is every kind of decorator and every kind of target. Functions,
methods, coroutines and classes; decorators written as functions and as
classes; with arguments and without.

The rest of the collection is four decorators worth having written once,
each a complete and useful thing rather than a demonstration. First,
caching, which you met in the opening workshop from the outside as
`@functools.cache` and now build from the inside.

**Caching results** is next.

Press Finish below to move on.
