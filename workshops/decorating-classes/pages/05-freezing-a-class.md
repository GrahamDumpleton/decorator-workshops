---
title: Freezing a class
requires: [verify:frozen]
---

# Freezing a class

Adding a method is one thing. A class decorator can also replace
behaviour the class already has, including the special methods that
control attribute access.

Making instances read-only after construction needs two changes at once,
which is a good reason for a decorator to do it: `__setattr__` has to
refuse assignments, but `__init__` has to be allowed to make them.

```{cell-insert}
:id: insert-frozen
:path: {{ notebook }}
:tags: [frozen]
:run: true
def frozen(cls):
    original_init = cls.__init__

    def __init__(self, *args, **kwargs):
        original_init(self, *args, **kwargs)
        object.__setattr__(self, "_frozen", True)

    def __setattr__(self, name, value):
        if getattr(self, "_frozen", False):
            raise AttributeError(f"{type(self).__name__} is frozen")
        object.__setattr__(self, name, value)

    cls.__init__ = __init__
    cls.__setattr__ = __setattr__
    return cls

@frozen
class Config:
    def __init__(self, host):
        self.host = host

config = Config("localhost")
built = config.host

try:
    config.host = "elsewhere"
    blocked = "no error"
except AttributeError as error:
    blocked = str(error)

print("built  :", built)
print("blocked:", blocked)
```

Construction works, assignment afterwards does not.

The flag is what separates the two. `__init__` runs first and sets
whatever it likes, then the replacement `__init__` marks the object
frozen, and from that moment `__setattr__` refuses.

`object.__setattr__(self, ...)` is doing necessary work in both places.
Writing `self._frozen = True` would go through the new `__setattr__`,
which would refuse it once the flag was set, and the plain assignment
inside the guard would call itself for ever. Going directly to
`object`'s version is how you set an attribute without re-entering your
own machinery.

This is also the pattern that shows why the decorator has to wrap
`__init__` rather than just add `__setattr__`. Two coordinated changes
to one class, applied together, from one line above the class
statement.

```{verify}
:id: frozen
:label: Built once, then refused
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed frozen
built == "localhost" and "frozen" in blocked
```
