---
title: Welcome
requires: [verify:announce-works]
---

# Decorators that take arguments

The decorators you have written so far are fixed: `@timer` always times,
`@repeat` would always repeat the same number of times. Real ones need
configuring, as `@retry(max_attempts=3)` does.

There are two separate problems in the way, and this workshop takes them
in order. The first is that a wrapper has to accept whatever arguments
the function it wraps accepts, which so far you have not had to think
about. The second is that `@repeat(3)` is a different shape of thing
from `@repeat`, and needs one more layer than you would expect.

The step below creates the notebook with a decorator that works, as long
as you never use it on anything else.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Decorators that take arguments
    Each step of the workshop adds a cell below.
- code: |
    def announce(func):
        def wrapper(name):
            print(f"calling {func.__name__}")
            return func(name)
        return wrapper

    @announce
    def greet(name):
        return f"Hello, {name}!"

    greet("Alice")
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

Look at `wrapper` before moving on. It takes exactly one argument called
`name`, and passes exactly that one on. It works here only because
`greet` happens to take one argument called `name` too.

```{verify}
:id: announce-works
:label: The decorated greet still greets
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
greet("Alice") == "Hello, Alice!"
```
