---
title: Adding a repr
requires: [verify:repr-added]
---

# Adding a repr

The default `repr` is the one thing almost every class wants replaced,
and it is the same code every time: the class name, then the attributes.
That makes it worth writing once.

```{cell-insert}
:id: insert-repr
:path: {{ notebook }}
:tags: [repr]
:run: true
def add_repr(cls):
    def __repr__(self):
        fields = ", ".join(f"{name}={value!r}" for name, value in vars(self).items())
        return f"{type(self).__name__}({fields})"

    cls.__repr__ = __repr__
    return cls

@add_repr
class Labelled:
    def __init__(self, x, y):
        self.x = x
        self.y = y

shown = repr(Labelled(1, 2))

print("repr:", shown)
```

One assignment to the class and every instance gets it, including ones
made later and ones made by code that has never heard of the decorator.

Two details worth noticing.

`vars(self)` is the instance dictionary, so the fields are whatever that
object actually has, rather than a list the decorator had to be told.
The `!r` in the f-string asks for each value's `repr`, which is what
keeps strings quoted.

And `type(self).__name__` is read at call time, not decoration time. A
subclass of `Labelled` gets a repr naming the subclass, without
inheriting a hard-coded name.

```{verify}
:id: repr-added
:label: The decorator gave the class a repr
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed repr
shown == "Labelled(x=1, y=2)"
```
