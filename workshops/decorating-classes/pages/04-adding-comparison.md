---
title: Adding comparison
requires: [verify:hash-trap]
---

# Adding comparison

Equality and ordering are the same kind of boilerplate, and they take an
argument: which attributes count. That is a decorator with the extra
layer from workshop four.

```{cell-insert}
:id: insert-comparison
:path: {{ notebook }}
:tags: [comparison]
:run: true
def add_comparison(*fields):
    def decorator(cls):
        def key(self):
            return tuple(getattr(self, name) for name in fields)

        cls.__eq__ = lambda self, other: (
            isinstance(other, cls) and key(self) == key(other)
        )
        cls.__lt__ = lambda self, other: key(self) < key(other)
        return cls

    return decorator

@add_comparison("x", "y")
@add_repr
class Pair:
    def __init__(self, x, y):
        self.x = x
        self.y = y

one, two = Pair(1, 2), Pair(1, 2)

equal = one == two
ordered = [repr(item) for item in sorted([Pair(3, 1), Pair(1, 9)])]

print("equal :", equal)
print("sorted:", ordered)
```

Both work, and the two decorators stack exactly as they did on
functions: `add_repr` applied first, `add_comparison("x", "y")` second,
each returning the class for the next one.

Now the part that catches people. Put those two equal objects in a set.

```{cell-insert}
:id: insert-hash
:path: {{ notebook }}
:tags: [hash]
:run: true
hash_removed = Pair.__hash__ is None
hashes_agree = hash(one) == hash(two)
in_a_set = len({one, two})

print("equal objects:", one == two)
print("__hash__ removed:", hash_removed)
print("hashes agree    :", hashes_agree)
print("size of a set holding both:", in_a_set)
```

Two objects that compare equal, and a set containing both of them.

A set finds candidates by hash before it compares anything, so two equal
objects with different hashes never meet. `Pair` still has the default
`__hash__`, which is based on identity, so `one` and `two` hash to
different places and the set keeps them apart. The same applies to
dictionary keys.

Python normally protects you from this. Define `__eq__` *in a class
body* and the interpreter sets `__hash__` to `None`, making instances
unhashable, so the mistake becomes an immediate `TypeError` instead of a
silent wrong answer.

```{cell-insert}
:id: insert-in-body
:path: {{ notebook }}
:tags: [in-body]
:run: true
class InBody:
    def __init__(self, x):
        self.x = x

    def __eq__(self, other):
        return self.x == other.x

body_hash_removed = InBody.__hash__ is None

print("__eq__ in the class body removes __hash__:", body_hash_removed)
```

That protection is applied when the class body is compiled. A decorator
assigns `__eq__` afterwards, so it never triggers, and the class is left
in exactly the state Python tries to prevent.

A decorator that adds `__eq__` has to decide what `__hash__` should be
and say so: `cls.__hash__ = lambda self: hash(key(self))` to match the
equality, or `cls.__hash__ = None` to make the objects unhashable on
purpose.

```{verify}
:id: hash-trap
:label: Equal objects, distinct hashes, and both in the set
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed in-body
equal and hash_removed is False and hashes_agree is False and in_a_set == 2 and body_hash_removed
```

```{hint}
:title: The standard library has this one
`functools.total_ordering` is a class decorator that fills in the rest
of the comparisons from `__eq__` and any one of `__lt__`, `__le__`,
`__gt__` or `__ge__`. It does not touch `__hash__` either, for the same
reason.
```
