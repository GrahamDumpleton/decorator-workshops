---
title: Welcome
requires: [verify:setup-ready]
---

# Decorators that are classes

`@name` means `f = name(f)`. Python never checks what `name` is. It
calls it, and binds the name to whatever comes back.

So a decorator does not have to be a function. Anything callable will
do, and a class is callable: calling it builds an instance. If that
instance is callable too, by having a `__call__` method, it can stand in
for the function.

That is the whole mechanism. What makes it worth using is state. A
function-based decorator that remembers something has to keep it in a
closure cell or hang it on the wrapper, both of which work and neither
of which is the obvious place to look. A class has attributes, which is
where a reader expects state to live.

The last workshop ended with a class-based decorator failing on a
method. That was real, and it comes back on the fifth page here. First,
what this kind is good at.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Decorators that are classes
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect

    def ping():
        """say pong"""
        return "pong"

    ping()
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

```{verify}
:id: setup-ready
:label: The undecorated function works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
ping() == "pong" and ping.__doc__ == "say pong"
```
