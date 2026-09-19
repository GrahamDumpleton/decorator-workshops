---
title: What a wrapper costs
requires: [verify:everything-lost]
---

# What a wrapper costs

Ask `greet` about itself. Not what it returns, which is fine, but what
it says it is.

```{cell-insert}
:id: insert-damage
:path: {{ notebook }}
:tags: [damage]
:run: true
print("__name__     :", greet.__name__)
print("__qualname__ :", greet.__qualname__)
print("__doc__      :", greet.__doc__)
print("signature    :", inspect.signature(greet))
print("__wrapped__? :", hasattr(greet, "__wrapped__"))
```

Everything is wrong, and wrong in a way that is hard to trace back to
its cause:

- The name is `wrapper`. Every function decorated with `@logged`, in
  the whole program, now calls itself `wrapper`, so a log line or a
  traceback naming `wrapper` cannot tell you which one.

- `__qualname__` says `logged.<locals>.wrapper`, which at least admits
  where it came from.

- The docstring is gone. `help(greet)` would show nothing useful, and a
  documentation tool would publish a page with no description.

- The signature is `(*args, **kwargs)`. Anything that reads parameter
  names to do its job, and plenty does, has nothing to work with. A web
  framework binding request fields to arguments, a CLI builder deriving
  options, a test framework matching fixtures: all of them see two
  anonymous catch-alls.

- There is no `__wrapped__`, so nothing can even find its way back to
  the original to ask it instead.

The function still works perfectly. It just cannot be identified or
described any more, which is the sort of bug that surfaces a long way
from its cause.

```{verify}
:id: everything-lost
:label: The wrapper has replaced the function's identity
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed damage
greet.__name__ == "wrapper" and greet.__doc__ is None and str(inspect.signature(greet)) == "(*args, **kwargs)"
```
