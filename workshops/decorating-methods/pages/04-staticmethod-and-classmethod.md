---
title: staticmethod and classmethod
requires: [verify:ordering]
---

# staticmethod and classmethod

`@staticmethod` and `@classmethod` are decorators too, so putting your
own alongside them is stacking, and the order matters in a way that is
easy to get wrong and easy to get away with.

All four combinations, each called both on the class and on an instance.

```{cell-insert}
:id: insert-ordering
:path: {{ notebook }}
:tags: [ordering]
:run: true
class Orders:
    @timer
    @staticmethod
    def a(x):
        return f"a{x}"

    @staticmethod
    @timer
    def b(x):
        return f"b{x}"

    @timer
    @classmethod
    def c(cls, x):
        return f"c{x}"

    @classmethod
    @timer
    def d(cls, x):
        return f"d{x}"

orders = Orders()
results = {}

for name in "abcd":
    for how, target in (("class", Orders), ("instance", orders)):
        try:
            results[f"{name} via {how}"] = getattr(target, name)(1)
        except TypeError as error:
            results[f"{name} via {how}"] = f"TypeError: {error}"

for key, value in results.items():
    print(f"{key:16} {value}")
```

Three different outcomes from one arrangement of two decorators:

- **`@classmethod` underneath fails always.** `c` raises
  `TypeError: 'classmethod' object is not callable`, whether you go
  through the class or an instance. `timer` was handed the
  `classmethod` object rather than a function, and tried to call it.

- **`@staticmethod` underneath half works, which is worse.** `a` is fine
  called on the class and raises
  `TypeError: takes 1 positional argument but 2 were given` called on an
  instance. A test that only ever calls `Orders.a(...)` passes, and the
  bug waits for the first caller who has an object in hand.

- **Both work the other way up.** `b` and `d` behave correctly through
  the class and through an instance.

So the rule is: `@staticmethod` and `@classmethod` go on top, your own
decorator underneath, closest to the `def`.

The reason follows from the last workshop. Applied bottom to top means
the decorator nearest the `def` goes on first, so putting yours there
means it wraps an ordinary function, which is what it was written for.
`staticmethod` and `classmethod` then wrap your wrapper and do their job
of deciding what gets passed on lookup, which is the last thing that
should happen, not the first.

```{verify}
:id: ordering
:label: The four combinations behave as the rule predicts
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed ordering
results["b via instance"] == "b1" and results["d via instance"] == "d1" and "TypeError" in results["c via class"] and "TypeError" in results["a via instance"] and results["a via class"] == "a1"
```

```{hint}
:title: If you have read the opposite rule
You may find advice saying your decorator goes above `@staticmethod`.
That was once the safer way round, because before Python 3.10 a
`staticmethod` object could not be called at all, so a decorator that
received one was in trouble immediately and obviously. Since 3.10 it is
callable, which turned a loud failure into the quiet half-working case
above. Checked on Python 3.14 in the cell you just ran.
```
