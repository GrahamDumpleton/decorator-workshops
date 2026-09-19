---
title: Welcome
requires: [verify:method-works]
---

# Decorating methods

Everything so far has decorated a plain function. Methods look like
functions, are written like functions, and mostly behave like
functions, so you would expect your decorators to work on them
unchanged.

Some do, exactly as they are. Others fail immediately with an error that
seems to be about something else entirely. This workshop is about which
is which, and why, because it is the single most common surprise people
meet with decorators.

The good news first. The kind of decorator you have been writing all
along, a function that returns a wrapper function, works on a method
with nothing changed.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Decorating methods
    Each step of the workshop adds a cell below.
- code: |
    import functools

    def timer(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            return func(*args, **kwargs)
        return wrapper

    class Shop:
        def __init__(self, name):
            self.name = name

        @timer
        def sell(self, item):
            return f"{self.name} sold {item}"

    shop = Shop("Corner Store")
    shop.sell("hat")
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

`shop.sell("hat")` works, and `self.name` inside the method found the
shop it belongs to. The decorator neither knew nor cared that it was
applied to a method.

```{verify}
:id: method-works
:label: The decorated method works and can see its instance
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
shop.sell("hat") == "Corner Store sold hat"
```
