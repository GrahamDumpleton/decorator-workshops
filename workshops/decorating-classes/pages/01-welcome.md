---
title: Welcome
requires: [verify:setup-ready]
---

# Decorating classes

`@name` means `f = name(f)`. Nothing in that says `f` has to be a
function.

A class is an object like any other, created when its body finishes
executing, and it can be passed to a function and bound to a name. So a
decorator can be applied to a class, and it receives the class itself.

This is the last kind of target left. You have decorated functions,
methods and coroutines, and written decorators as functions and as
classes. The very first workshop put `@dataclasses.dataclass` on a class
and moved on without explaining it. This is that explanation.

In **Decorators that are classes** the decorator itself was a class.
This is the opposite arrangement: an ordinary decorator, applied to a
class. The two are worth keeping apart, because the names are nearly
identical and the ideas are unrelated. One is about what the decorator
is made of, the other about what it is given.

The step below creates the notebook this workshop uses, with a plain
class that has no `__repr__` of its own.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Decorating classes
    Each step of the workshop adds a cell below.
- code: |
    import dataclasses

    class Point:
        def __init__(self, x, y):
            self.x = x
            self.y = y

    point = Point(1, 2)

    print(repr(point))
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

The default `repr` tells you the class and an address, which is the
least a debugger could say. Fixing that is the first thing a class
decorator will do.

```{verify}
:id: setup-ready
:label: The plain class has the default repr
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
point.x == 1 and "Point object at" in repr(point)
```
