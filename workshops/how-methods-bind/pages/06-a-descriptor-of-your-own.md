---
title: A descriptor of your own
requires: [verify:validated]
---

# A descriptor of your own

Everything so far used descriptors to fix a decorator, which makes them
look like a decorator technique. They are not. They are how attribute
access works, and they are just as useful with no decorator anywhere.

A managed attribute is the clearest example: one that checks what it is
given, every time it is set.

```{cell-insert}
:id: insert-validated
:path: {{ notebook }}
:tags: [validated]
:run: true
class Positive:
    """An attribute that refuses anything but a positive number."""

    def __set_name__(self, owner, name):
        self.label = name
        self.storage = "_" + name

    def __get__(self, instance, owner=None):
        if instance is None:
            return self
        return getattr(instance, self.storage)

    def __set__(self, instance, value):
        if value <= 0:
            raise ValueError(f"{self.label} must be positive, got {value}")
        setattr(instance, self.storage, value)

class Order:
    quantity = Positive()

    def __init__(self, quantity):
        self.quantity = quantity

good = Order(5).quantity

try:
    Order(0)
    rejected = "no error"
except ValueError as error:
    rejected = str(error)

print("accepted:", good)
print("rejected:", rejected)
```

`self.quantity = quantity` inside `__init__` looks like an ordinary
assignment, and it runs `Positive.__set__`. The check happens at
construction and at every assignment afterwards, with no call for the
caller to remember to make.

This one defines `__set__`, so it is a data descriptor, and the
instance dictionary cannot shadow it. That is why the value is kept
under a different name, `_quantity`, rather than under `quantity`: the
descriptor needs somewhere to put it that does not go back through
itself.

You have now met the protocol in both directions. A function uses
`__get__` to bind. `@property` is a data descriptor with `__get__` and
`__set__`. `@staticmethod` and `@classmethod` are descriptors whose
`__get__` returns something other than a bound method. None of them are
special cases in the interpreter; they are all this protocol.

```{verify}
:id: validated
:label: The attribute validated on assignment
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed validated
good == 5 and "must be positive" in rejected
```
