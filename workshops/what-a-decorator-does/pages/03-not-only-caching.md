---
title: Not only caching
requires: [verify:property-and-dataclass]
---

# Not only caching

Caching is one thing a decorator can do, not what decorators are for.
Here are two more from the standard library that do something completely
different.

`@property` turns a method into an attribute. `total` below is written
as a method, with `self` and a body, but it is read without parentheses,
and it runs every time it is read.

```{cell-insert}
:id: insert-property
:path: {{ notebook }}
:tags: [property]
:run: true
class Order:
    def __init__(self, quantity, unit_price):
        self.quantity = quantity
        self.unit_price = unit_price

    @property
    def total(self):
        return self.quantity * self.unit_price

order = Order(3, 250)
order.total
```

`order.total` gives 750, with no `()` anywhere. Change `order.quantity`
and read it again and the answer changes, because it is a method
pretending to be an attribute.

There is a second effect, which is the point of using it: the attribute
is now read only.

```{cell-insert}
:id: insert-readonly
:path: {{ notebook }}
:tags: [readonly]
:run: true
try:
    order.total = 999
    message = "no error"
except AttributeError as error:
    message = str(error)

message
```

Python refuses, because the property has no setter. A plain attribute
would have accepted 999 without complaint.

The third one decorates a class rather than a function.
`@dataclasses.dataclass` looks at the annotations you wrote and writes
the boring methods for you.

```{cell-insert}
:id: insert-dataclass
:path: {{ notebook }}
:tags: [dataclass]
:run: true
import dataclasses

@dataclasses.dataclass
class Point:
    x: int
    y: int = 0

point = Point(1, 2)
print(repr(point))
print(Point(1, 2) == Point(1, 2))
```

Nobody wrote `__init__`, yet `Point(1, 2)` works. Nobody wrote
`__repr__`, yet printing it is readable. Nobody wrote `__eq__`, yet two
separate points compare equal. Without the decorator, that last line
would be `False`, because two different objects are not the same object.

Three decorators, three completely different changes: a function that
skips work, a method that reads as an attribute, a class that gains
methods. What they have in common is not what they do. It is how they
are attached.

```{verify}
:id: property-and-dataclass
:label: The property is read only and the dataclass has its methods
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed dataclass
"setter" in message and repr(point) == "Point(x=1, y=2)" and Point(1, 2) == Point(1, 2)
```

```{hint}
:title: If the check fails
All three cells on this page need to have been run, in order: the class
with the property, the cell that tries to assign to it, and the
dataclass.
```
