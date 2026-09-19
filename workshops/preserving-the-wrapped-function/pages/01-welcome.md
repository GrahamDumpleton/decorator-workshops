---
title: Welcome
requires: [verify:greet-works]
---

# Preserving the wrapped function

This is a short workshop about a one line fix, and about the damage it
prevents.

Every decorator you have written replaces a function with a wrapper.
That was the point. But the wrapper is a different object with a
different name, no docstring, and a parameter list of `*args, **kwargs`,
and from the outside your function now looks like that instead of like
itself.

Nothing has depended on it yet. It starts mattering the moment anything
inspects your function rather than calling it: `help()`, documentation
tools, debuggers, test frameworks that look at parameter names, and you,
reading a traceback.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Preserving the wrapped function
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect

    def logged(func):
        def wrapper(*args, **kwargs):
            return func(*args, **kwargs)
        return wrapper

    @logged
    def greet(name, greeting="Hello"):
        """Greet someone by name."""
        return f"{greeting}, {name}!"

    greet("Alice")
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

`greet` has everything a function should have: a name, two parameters,
one with a default, and a docstring saying what it does.

```{verify}
:id: greet-works
:label: The decorated greet still greets
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
greet("Alice") == "Hello, Alice!"
```
