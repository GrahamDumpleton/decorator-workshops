---
title: Welcome
requires: [verify:decorated-ready]
---

# How a decorator remembers

Here is the puzzle this workshop answers.

A decorator takes a function, defines a wrapper, and returns it. Then it
is finished. Its local variables, `func` among them, should be gone, the
way a function's locals always are once it returns.

But the wrapper goes on calling `func` for as long as your program runs.
Something keeps it alive, and in Python you can look straight at it.

The step below creates the notebook with a decorator and a function to
decorate. This is the same shape you wrote in the last workshop, cut
down to the parts that matter here.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # How a decorator remembers
    Each step of the workshop adds a cell below.
- code: |
    def logging_wrapper(func):
        def wrapper(*args, **kwargs):
            print(f"calling {func.__name__}")
            return func(*args, **kwargs)
        return wrapper

    def greet(name):
        return f"Hello, {name}!"

    decorated = logging_wrapper(greet)
    decorated.__name__
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

Note that this keeps two names: `greet` is still the original function,
and `decorated` is the wrapper. Keeping them apart makes the next page
easier to read.

`logging_wrapper` has already returned. As far as Python is concerned it
is over and done with.

```{verify}
:id: decorated-ready
:label: The wrapper exists and the original is still around
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
decorated.__name__ == "wrapper" and greet.__name__ == "greet"
```
