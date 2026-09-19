---
title: Welcome
requires: [verify:async-works]
---

# Decorating async functions

An `async def` looks like a function and is decorated like a function,
so your decorators go on it without complaint. Some of them then do
nothing useful, and say nothing about it.

The reason is one fact worth stating plainly before anything else:
**calling an async function does not run it.** It builds a coroutine, an
object describing work that has not started. The work happens when
something awaits it.

Every wrapper you have written assumes that `func(*args, **kwargs)` does
the work. For an `async def` it does not, so the wrapper measures
nothing, retries nothing, and hands the caller an object rather than an
answer.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Decorating async functions
    Each step of the workshop adds a cell below.
- code: |
    import asyncio
    import functools
    import inspect
    import time

    async def fetch(item):
        await asyncio.sleep(0.05)
        return f"got {item}"

    result = await fetch("hat")
    result
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

Note the `await` on the last line, written straight into the cell. A
notebook runs cells inside an event loop already, so top level `await`
works here exactly as it would inside an `async def`.

That is also why nothing in this workshop calls `asyncio.run()`. There
is already a loop running, and `asyncio.run` demands one that is not.

```{verify}
:id: async-works
:label: The async function ran and returned its value
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
result == "got hat"
```
