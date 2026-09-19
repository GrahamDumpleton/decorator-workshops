---
title: Welcome
requires: [verify:function-works]
---

# What a decorator does

A decorator is a line beginning with `@` above a `def` or a `class`. It
changes what that function or class does, without changing a single line
inside it.

You are not going to write one in this workshop. You are going to use
three that come with Python, and watch what each one changes. Writing
your own comes next, and it is much easier once you have seen what they
are for.

Everything happens in a notebook. The step below creates it with a
function to experiment on: `lookup_price` is slow, because it pretends
to ask a server, and it always gives the same answer for the same item.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # What a decorator does
    Each step of the workshop adds a cell below.
- code: |
    import time

    def lookup_price(item):
        time.sleep(0.05)
        return len(item) * 10

    lookup_price("widget")
  tags: [setup]
```

Run the cell to define the function and see what it answers.

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

```{verify}
:id: function-works
:label: The function is defined and returns a price
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
lookup_price("widget") == 60
```

```{hint}
:title: If the check says lookup_price is not defined
The cell has not run yet, or it ran in a different notebook. Use the
step above, which runs the cell tagged `setup` in this workshop's
notebook.
```
