---
title: Before, after and instead
requires: [verify:three-positions]
---

# Before, after and instead

Every wrapper you have written has the same three slots: code before the
call, the call itself, code after it. Naming them makes the pattern
obvious.

```{cell-insert}
:id: insert-around
:path: {{ notebook }}
:tags: [around]
:run: true
def announce(func):
    def wrapper(*args, **kwargs):
        print("before")
        result = func(*args, **kwargs)
        print("after")
        return result
    return wrapper

@announce
def work():
    print("  doing the work")
    return "done"

outcome = work()
print("work returned:", outcome)
```

The output reads outside in: `before`, the function's own line, then
`after`. Logging used the first and third slots. Timing used them too,
to read a clock twice. Counting used only the first.

The slot people forget is the one where you do not call the function at
all. Nothing obliges a wrapper to call what it wraps.

```{cell-insert}
:id: insert-instead
:path: {{ notebook }}
:tags: [instead]
:run: true
def disabled(func):
    def wrapper(*args, **kwargs):
        print(f"{func.__name__} was not called")
        return None
    return wrapper

@disabled
def send_email(to):
    print(f"sending to {to}")
    return "sent"

sent = send_email("alice@example.org")
print("send_email returned:", sent)
```

No email, and `sent` is `None`. `send_email` is untouched and still
perfectly capable of sending; the wrapper simply never asks it to.

That is the same power `@functools.cache` used in the first workshop.
Caching is not a special feature: it is a wrapper deciding, on the
second call, that it already knows the answer and need not call the
function at all.

```{verify}
:id: three-positions
:label: The wrapper ran around one call and instead of the other
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed instead
outcome == "done" and sent is None
```

```{hint}
:title: A wrapper can change the arguments too
It can. `func(*args, **kwargs)` passes on what it was given, but nothing
stops a wrapper passing something else, or changing the result before
returning it. Validation, retries and normalising arguments are all
that idea.
```
