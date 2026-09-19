---
title: Welcome
requires: [verify:fib-works]
---

# Caching results

The very first workshop put `@functools.cache` on a slow function and
the second call came back instantly. You used it without knowing what it
was.

Now you build it. A cache is the clearest decorator there is: it keeps
what the function returned, and next time the same question is asked it
answers from memory instead of doing the work again.

It is also the clearest illustration of why decorators are worth having.
The caching has nothing to do with the function's job, applies equally
to any function, and can be added or removed by touching one line.

The step below creates the notebook with a function that is slow for a
reason worth seeing: recursive Fibonacci recomputes the same values
over and over, so the saving is dramatic rather than theoretical.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Caching results
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import inspect
    import time

    runs = {"count": 0}

    def fib(n):
        runs["count"] += 1
        return n if n < 2 else fib(n - 1) + fib(n - 2)

    fib(20), runs["count"]
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

`fib(20)` is 6765, and the body ran **21891 times** to work it out.
Almost all of that is recomputation: `fib(18)` alone is calculated
thousands of times over.

```{verify}
:id: fib-works
:label: The uncached version works, expensively
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
fib(20) == 6765 and runs["count"] > 20000
```
