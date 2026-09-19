---
title: Translating errors
requires: [verify:cause-kept]
---

# Translating errors

The second one. A module that reads settings from a file should not make
its callers catch `FileNotFoundError`, `PermissionError` and
`IsADirectoryError` individually: that is the filesystem's vocabulary
leaking through an interface that ought to speak its own.

A decorator can translate, catching the low level exception and raising
one of yours in its place.

```{cell-insert}
:id: insert-translate
:path: {{ notebook }}
:tags: [translate]
:run: true
class StorageError(Exception):
    """Anything that went wrong reading stored settings."""

def translate(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except OSError as error:
            raise StorageError("could not read settings") from error
    return wrapper

@translate
def read_settings():
    raise FileNotFoundError("settings.toml")

try:
    read_settings()
    raised = None
except StorageError as error:
    raised = error

print("raised   :", type(raised).__name__, "-", raised)
print("caused by:", type(raised.__cause__).__name__, "-", raised.__cause__)
```

The caller now catches `StorageError`, and `OSError` stays an
implementation detail. `OSError` is the right thing to catch, since
`FileNotFoundError` and `PermissionError` are both subclasses of it.

`from error` is what makes this safe rather than destructive. It sets
`__cause__` on the new exception, so the original is still attached, and
a traceback prints both with "The above exception was the direct cause
of the following exception" between them. Whoever debugs this at three
in the morning can still see which file was missing.

Leave `from error` off and the original is not entirely lost, since
Python sets `__context__` for an exception raised inside an `except`
block and the traceback says "During handling of the above exception,
another exception occurred". But that reads as an accident, a second
failure while dealing with the first, which is not what you meant.
`from` says the translation was deliberate.

```{verify}
:id: cause-kept
:label: The error was translated and its cause preserved
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed translate
type(raised).__name__ == "StorageError" and isinstance(raised.__cause__, FileNotFoundError)
```

```{hint}
:title: The fourth decorator, and when not to use it
The other one people write is `@suppress(ValueError, default=None)`,
catching and returning a default instead. It is occasionally right, for
a genuinely optional lookup, and it is the one to be most suspicious of:
it turns a failure into a plausible value, which is how a wrong number
ends up in a report with nothing in the logs to explain it.
```
