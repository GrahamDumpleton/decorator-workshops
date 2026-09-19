---
title: Wrapping by hand
requires: [verify:wrapped-by-hand]
---

# Wrapping by hand

Say you want to see every call to `greet`: what went in, what came out.
You could edit `greet` and add two `print` calls. But then every other
function you want to watch needs the same edit, and `greet` is now
partly about logging instead of only about greeting.

Instead, write a function that builds a replacement.

`logging_wrapper` takes a function and returns a new one. The new one
prints, calls the original, prints again, and hands back the original's
answer. Read it before you run it: the shape here is the shape of every
decorator you will ever write.

```{cell-insert}
:id: insert-by-hand
:path: {{ notebook }}
:tags: [by-hand]
:run: true
def logging_wrapper(func):
    def wrapper(*args, **kwargs):
        print(f"calling {func.__name__}")
        result = func(*args, **kwargs)
        print(f"{func.__name__} returned {result!r}")
        return result
    return wrapper

greet = logging_wrapper(greet)

result = greet("Alice")
```

Four things happened in that last line but one, and each is worth
naming:

- `logging_wrapper(greet)` ran once, then and there. It did not call
  `greet`; it only built `wrapper` and returned it.

- The name `greet` now points at `wrapper`. The original function still
  exists, but the only thing holding it is `wrapper` itself.

- `wrapper` takes `*args, **kwargs` and passes them straight through,
  so it accepts whatever the original accepted. It never has to know
  that `greet` takes one argument called `name`.

- `wrapper` returns `result`. Forget that `return` and every decorated
  function in your program silently starts returning `None`, which is a
  bug people spend afternoons on.

```{verify}
:id: wrapped-by-hand
:label: greet is now the wrapper, and still greets
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed by-hand
result == "Hello, Alice!" and greet.__name__ == "wrapper"
```

```{hint}
:title: greet.__name__ says "wrapper" now
That is not a mistake, and it is not harmless either. The name `greet`
points at a function that really is called `wrapper`, so introspection,
`help()` and tracebacks all say so. There is a standard fix, and it has
a workshop of its own later in this collection.
```
