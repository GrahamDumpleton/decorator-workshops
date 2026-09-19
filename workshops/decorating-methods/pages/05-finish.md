---
title: What you know now
requires: [quiz:why-it-broke]
---

# What you know now

A decorator that returns a function works on a method with no changes,
because the thing it hands back is still a function, and functions know
how to bind themselves to an instance.

A decorator that returns something else, a class instance most commonly,
breaks that. The attribute no longer knows how to bind, the instance is
never passed, every argument shifts along by one, and the error names
the argument that fell off the end rather than the `self` that never
arrived.

When a decorator wants the instance, it is simply the first positional
argument by the time the wrapper runs. Take it by name if the decorator
is only for methods, and be aware that this is the choice that makes it
only for methods.

And `@staticmethod` or `@classmethod` goes above your own decorator, not
below it, which is the opposite of some advice you will find.

```{quiz}
:id: why-it-broke
:title: Why one worked and one did not
:shuffle: true
question: "Why does a function-based decorator work on a method when a class-based one does not?"
options:
  - text: "Because the function-based one returns a function, and functions bind themselves to the instance on lookup."
    correct: true
  - text: "Because a class instance cannot be called, so it cannot stand in for a method."
    explanation: "It can be called: that is what `__call__` is for, and it works fine on a plain function. The problem is binding, which happens on lookup, before any call."
  - text: "Because the class-based one forgot to accept `self` in `__call__`."
    explanation: "`__call__` took `*args`, so it would have accepted an instance quite happily. Nothing passed it one."
  - text: "Because decorators cannot be used inside a class body."
    explanation: "They can, and the `timer` version on the first page did exactly that and worked."
explanation: "A method is an ordinary function until it is looked up on an instance, at which point the function's own `__get__` supplies the instance as the first argument. A decorator that returns a function preserves that. One that returns a plain object loses it."
```

## Where this goes next

The class-based decorator broke here, which makes it look like the wrong
tool. It is not: it is the better tool whenever a decorator has state to
keep, because an instance attribute is a more honest place for a count
or a cache than a variable captured in a closure.

The next workshop takes that kind seriously: what it is good at, how to
keep its identity, how its constructor replaces the extra layer that
`@repeat(3)` needed, and what it takes to make one work on methods after
all.

**Decorators that are classes** is next.

Press Finish below to move on.
