---
title: Keeping the identity
requires: [verify:identity-restored]
---

# Keeping the identity

Workshop five was about a wrapper replacing a function's identity. A
class does the same thing, and does it worse, because the replacement is
not even the same kind of object.

Ask the decorated `ping` what it is.

```{cell-insert}
:id: insert-lost
:path: {{ notebook }}
:tags: [lost]
:run: true
before_name = getattr(ping, "__name__", "<missing>")
before_doc = ping.__doc__

print("__name__ :", before_name)
print("__doc__  :", before_doc)
print("signature:", inspect.signature(ping))
```

Worse than the function case in two ways.

There is no `__name__` at all. A function-based wrapper at least had
one, even if it said `wrapper`; an instance has none, so code that reads
`func.__name__` raises `AttributeError` rather than reporting something
unhelpful.

And the docstring is not missing, it is wrong. `ping.__doc__` falls back
to the class's docstring, so it confidently describes the decorator
instead of the function. A documentation tool would publish "Count how
many times the decorated function is called" as the description of
`ping`. Nothing is broken enough to notice, which is what makes it bad.

The fix is the same machinery as `functools.wraps`, applied to an object
rather than a function. `wraps` is a decorator for convenience;
`update_wrapper` is the function underneath it, and it takes the thing
to fix and the thing to copy from.

```{cell-insert}
:id: insert-update
:path: {{ notebook }}
:tags: [update]
:run: true
class Counted:
    """Count how many times the decorated function is called."""

    def __init__(self, func):
        functools.update_wrapper(self, func)
        self.func = func
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(*args, **kwargs)

@Counted
def ping():
    """say pong"""
    return "pong"

print("__name__ :", ping.__name__)
print("__doc__  :", ping.__doc__)
print("signature:", inspect.signature(ping))
print("wrapped  :", ping.__wrapped__.__name__)
```

Name, docstring and signature all correct, and `__wrapped__` points at
the original, which is what `inspect` followed to report the signature.
`self.count` still works: `update_wrapper` copies identity, it does not
interfere with the attributes the decorator keeps for itself.

```{verify}
:id: identity-restored
:label: The identity was wrong, and update_wrapper fixed it
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed update
before_name == "<missing>" and "Count how many" in before_doc and ping.__name__ == "ping" and ping.__doc__ == "say pong"
```

```{hint}
:title: Order matters inside __init__
Call `update_wrapper` before setting your own attributes, as here. It
merges the wrapped function's `__dict__` into the instance, so calling
it afterwards can overwrite something you have just set if the names
collide.
```
