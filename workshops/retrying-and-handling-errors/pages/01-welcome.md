---
title: Welcome
requires: [verify:logging-ready]
---

# Retrying and handling errors

A wrapper sits between the caller and the function, which puts it in the
one place that sees every failure. That makes error handling a natural
thing to decorate, and this workshop writes the four decorators worth
having: log it, translate it, retry it, or suppress it.

Workshop two covered the mechanics of a wrapper that survives an
exception, with `try`/`finally`. This one is about deciding what to *do*
with the exception.

Real code logs through the `logging` module rather than `print`, so the
setup below sends log records into a list. That is only so you can see
and check them here; everything else is what you would actually write.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Retrying and handling errors
    Each step of the workshop adds a cell below.
- code: |
    import functools
    import logging
    import time

    records = []

    class ListHandler(logging.Handler):
        def emit(self, record):
            records.append(record.getMessage())

    logger = logging.getLogger("workshop")
    logger.setLevel(logging.DEBUG)
    logger.handlers.clear()
    logger.addHandler(ListHandler())
    logger.propagate = False

    logger.info("logging is set up")
    records
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

```{verify}
:id: logging-ready
:label: Log records are being captured
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
records == ["logging is set up"]
```
