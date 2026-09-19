---
title: With and without parentheses
requires: [verify:dual-use-works]
---

# With and without parentheses

You now have two shapes that look almost identical and are not. `@debug`
hands the function to `debug`. `@debug("###")` calls `debug` first and
hands the function to what comes back.

Most decorators pick one. Some want both, so that the common case needs
no empty parentheses, and people do expect that: `@functools.cache`
works bare, and typing `@functools.cache()` is a mistake people make
constantly.

Supporting both means looking at what you were given. A decorator used
bare receives a function; used with settings it receives the settings.

```{cell-insert}
:id: insert-dual
:path: {{ notebook }}
:tags: [dual]
:run: true
def debug(arg=None):
    if callable(arg):
        func, prefix = arg, ">>>"

        def wrapper(*args, **kwargs):
            return f"{prefix} {func(*args, **kwargs)}"

        return wrapper

    prefix = arg or ">>>"

    def decorator(func):
        def wrapper(*args, **kwargs):
            return f"{prefix} {func(*args, **kwargs)}"
        return wrapper

    return decorator

@debug
def bare():
    return "no parentheses"

@debug("###")
def configured():
    return "with parentheses"

print(bare())
print(configured())
```

Both work. The `callable(arg)` test is the whole trick: a function was
passed, so this is the bare form and the work happens now; otherwise a
setting was passed, so return a decorator and wait to be handed the
function.

The cost is in the duplication, and it is worth seeing rather than
being told. The wrapper is written twice, once in each branch. Real
code hoists it out or uses `functools.partial` to call `debug` again
with the settings filled in, which is tidier and does the same thing.

There is also a case this cannot get right, and it is not a bug you can
fix by being cleverer.

```{cell-insert}
:id: insert-ambiguous
:path: {{ notebook }}
:tags: [ambiguous]
:run: true
try:
    @debug(str.upper)
    def odd():
        return "x"

    ambiguous = odd()
except TypeError as error:
    ambiguous = f"TypeError: {error}"

print(ambiguous)
```

`str.upper` is a callable, so `debug` took it for the function being
decorated rather than for a setting. If a decorator's settings can
themselves be callables, and plenty can (a key function, a validator, a
factory), then "was I given a function?" no longer answers "was I used
bare?".

The way out is not detection but a rule: make the settings keyword only,
with `def debug(func=None, *, prefix=">>>")`. Then `@debug(prefix=...)`
is unambiguous whatever the value, and the only positional argument a
caller can pass is the function itself.

```{verify}
:id: dual-use-works
:label: Both forms work, and the ambiguous case is visible
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed ambiguous
bare() == ">>> no parentheses" and configured() == "### with parentheses" and "TypeError" in ambiguous
```

```{hint}
:title: The simplest advice
Pick one form and document it. Supporting both is a convenience for
users of a widely used library, and a source of confusing bugs
everywhere else. If you do support both, make the settings keyword only
and the ambiguity disappears.
```
