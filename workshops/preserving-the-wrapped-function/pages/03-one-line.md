---
title: One line
requires: [verify:identity-restored]
---

# One line

`functools.wraps` is a decorator you apply to your wrapper, naming the
function being wrapped. It copies the identity across.

Write `logged` again with it. Nothing else about the decorator changes.

```{cell-insert}
:id: insert-wraps
:path: {{ notebook }}
:tags: [wraps]
:run: true
def logged(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@logged
def greet(name, greeting="Hello"):
    """Greet someone by name."""
    return f"{greeting}, {name}!"

print("__name__     :", greet.__name__)
print("__qualname__ :", greet.__qualname__)
print("__doc__      :", greet.__doc__)
print("signature    :", inspect.signature(greet))
print("__wrapped__  :", greet.__wrapped__.__name__)
```

All five answers are now the ones you would want. The name is `greet`,
the docstring is back, and `help(greet)` in a cell of your own would
print the real thing.

The signature is worth pausing on, because it is not a copy. `wraps`
sets `__wrapped__` to point at the original, and `inspect.signature`
follows that link and reports what it finds at the end of it. The
wrapper's own parameters really are still `*args, **kwargs`; `inspect`
is choosing to answer about the function you meant rather than the one
standing in for it. The same is true of `inspect.getsource`, which
follows the link and shows you the original's source.

That one link is doing most of the work, and it is why a decorator that
forgets `wraps` loses everything at once: without `__wrapped__` there is
nothing to follow, so the name, the docstring, the signature and the
source are all gone together, as you saw on the last page.

```{verify}
:id: identity-restored
:label: wraps restored the name, the docstring and the signature
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed wraps
greet.__name__ == "greet" and greet.__doc__ == "Greet someone by name." and str(inspect.signature(greet)) == "(name, greeting='Hello')" and greet.__wrapped__.__name__ == "greet"
```

```{hint}
:title: If you have read that wraps does not fix the signature
It is a common claim and it is out of date. It was true before
`inspect` learned to follow `__wrapped__`, which it has done since
Python 3.4. You can check any claim like this in a cell of your own in
seconds, which is worth doing: decorators attract folklore.
```
