---
title: What dataclass is
requires: [verify:dataclass]
---

# What `dataclass` is

The first workshop put `@dataclasses.dataclass` on a class, watched it
produce `__init__`, `__repr__` and `__eq__` out of nothing, and left it
there as something to come back to.

You have now written the two smaller versions of it by hand. Here it is
next to what it actually is.

```{cell-insert}
:id: insert-dataclass
:path: {{ notebook }}
:tags: [dataclass]
:run: true
@dataclasses.dataclass
class Vector:
    x: int
    y: int

class Manual:
    x: int
    y: int

Manual = dataclasses.dataclass(Manual)

by_at = repr(Vector(1, 2))
by_hand = repr(Manual(1, 2))
is_a = type(dataclasses.dataclass).__name__
dataclass_hash_removed = Vector.__hash__ is None

print("with @ :", by_at)
print("by hand:", by_hand)
print("dataclasses.dataclass is a:", is_a)
print("__hash__ removed:", dataclass_hash_removed)
```

`dataclasses.dataclass` is a function. Applying it with `@` and calling
it by hand produce the same result, because `@dataclass` on a class
means `Manual = dataclass(Manual)`, which is the rule from the very
first workshop with a class in place of a function.

It reads the annotations in the class body, writes `__init__`,
`__repr__` and `__eq__` from them, and returns the same class with those
methods attached. Exactly what `add_repr` and `add_comparison` did, for
more methods and with better error messages.

And it does the thing the last page said a careful decorator has to do.
Having added `__eq__`, it sets `__hash__` to `None`, so `Vector`
instances are unhashable rather than quietly wrong in a set. That is the
deliberate choice your own `add_comparison` skipped, and the reason
`@dataclass(frozen=True)` exists: a frozen dataclass cannot be mutated,
so hashing by value is safe, and it gives you a real `__hash__` instead.

```{verify}
:id: dataclass
:label: The @ form and the by-hand form agree
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed dataclass
by_at == "Vector(x=1, y=2)" and by_hand == "Manual(x=1, y=2)" and is_a == "function" and dataclass_hash_removed
```
