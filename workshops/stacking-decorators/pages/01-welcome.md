---
title: Welcome
requires: [verify:setup-ready]
---

# Stacking decorators

Nothing stops you putting two decorators on one function, and real code
does it constantly: a route and a permission check, a cache and a timer,
a retry and a log.

As soon as there are two, there is an order, and it is worth being
precise about because there are really two orders. The order the
decorators are applied in, when the function is defined, and the order
they run in, on every call. They are opposites, which is where the
confusion starts.

The step below creates the notebook with two decorators that are easy to
see the effect of: one wraps its result in `<b>` tags, the other in
`<i>`.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Stacking decorators
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect

    def bold(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            return f"<b>{func(*args, **kwargs)}</b>"
        return wrapper

    def italic(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            return f"<i>{func(*args, **kwargs)}</i>"
        return wrapper

    def plain():
        return "hi"

    plain()
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

Both use `@functools.wraps`, from the last workshop, so nothing here
loses its identity along the way. That matters more than usual once
there is a stack, as the last page shows.

```{verify}
:id: setup-ready
:label: The decorators are defined and the plain function works
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
plain() == "hi" and callable(bold) and callable(italic)
```
