---
title: A decorator on a class
requires: [verify:receives-the-class]
---

# A decorator on a class

Before changing anything, confirm what arrives. A decorator on a class
is handed the class object, after the body has run and the class exists.

```{cell-insert}
:id: insert-target
:path: {{ notebook }}
:tags: [target]
:run: true
seen = []

def show_target(cls):
    seen.append(cls.__name__)
    return cls

@show_target
class Widget:
    def __init__(self, size):
        self.size = size

received = seen[0]
same_object = show_target(Widget) is Widget
kind = type(Widget).__name__

print("the decorator received:", received)
print("it handed back the same object:", same_object)
print("Widget is still a:", kind)
print("and it still works:", Widget(3).size)
```

The decorator received `Widget`, the class itself, not an instance.
Nothing has been wrapped and nothing replaced: it returned the same
object it was given, and `Widget` is still an ordinary class.

That is the simplest useful shape, and it is the registration pattern
applied to classes rather than functions. Take the class, record it
somewhere, hand it straight back.

What makes class decorators interesting is the second option. The class
is mutable, so a decorator can add to it before returning it, and every
instance made afterwards has whatever was added. That is what the next
three pages do.

A decorator could also return something else entirely, as any decorator
can. It is rarely a good idea here: returning a different object from
the one the `class` statement created is a reliable way to confuse
everything that later checks `isinstance`.

```{verify}
:id: receives-the-class
:label: The decorator received the class and returned it unchanged
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed target
received == "Widget" and same_object and kind == "type"
```
