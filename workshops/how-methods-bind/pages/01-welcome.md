---
title: Welcome
requires: [verify:setup-ready]
---

# How methods bind

You have written `obj.method()` thousands of times. Something has to
turn that into a call that knows about `obj`, because the function in
the class body takes `self` and nothing at the call site passes it.

That something is the descriptor protocol. It has been named more than
once in this collection and explained none of those times: when a
decorator broke on a method, and again when a class-based decorator
broke on one in a different way. This workshop explains it.

It is worth knowing for its own sake. Binding is not a special case the
interpreter hard-codes for methods; it is an ordinary protocol, written
in Python, that you can use on your own objects. Once you have seen it,
`@property`, `@staticmethod` and `@classmethod` stop being magic.

The step below creates the notebook this workshop uses, with the
imports and a plain class to start from.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # How methods bind
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import types

    class Service:
        """A plain class, with a plain method."""

        def __init__(self, name):
            self.name = name

        def call(self):
            return f"ok from {self.name}"

    service = Service("one")

    print(service.call())
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

```{verify}
:id: setup-ready
:label: The plain class works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
service.call() == "ok from one"
```
