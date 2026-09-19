---
title: What you know now
requires: [quiz:why-three-layers]
---

# What you know now

Two separate problems, solved separately.

A wrapper has to fit whatever it wraps, so it takes `*args, **kwargs`
and passes them straight on, with the stars at both ends and a `return`
in front. That is what makes one decorator usable on every function
rather than on the one it was written beside.

A decorator that takes settings needs one more layer than a plain one,
because `@repeat(3)` calls `repeat` before the decoration happens. Three
nested functions, each with one job: settings, then function, then call.

```python
def repeat(times):            # the settings
    def decorator(func):      # the function being decorated
        def wrapper(*args, **kwargs):   # the call
            ...
        return wrapper
    return decorator
```

You also built a `@retry` that gives up loudly rather than silently, and
saw why a decorator that supports both `@debug` and `@debug("###")` has
a case it cannot get right unless its settings are keyword only.

```{quiz}
:id: why-three-layers
:title: Why three layers
:shuffle: true
question: "Why does `@repeat(3)` need three nested functions where `@timer` needs two?"
options:
  - text: "Because `repeat(3)` runs first and must return something that can be applied to the function."
    correct: true
  - text: "Because the wrapper needs somewhere to store the number 3."
    explanation: "The wrapper reads `times` from the enclosing scope through its closure, which needs no extra layer. The layer exists because of when the call happens, not where the value lives."
  - text: "Because decorators with arguments are applied three times."
    explanation: "It is applied once. The three functions run at three different moments: `repeat(3)` at decoration, `decorator` immediately after, and `wrapper` on every call."
  - text: "Because Python requires a factory function for any decorator taking parameters."
    explanation: "Python requires nothing of the sort. `@` simply calls whatever expression follows it. The shape falls out of that one rule."
explanation: "`@repeat(3)` means `repeat(3)` runs first, and whatever it returns is then applied to the function. So `repeat` returns a decorator, and that decorator returns the wrapper."
```

## Where this goes next

Every decorator you have written replaces a function with a wrapper, and
the wrapper is not the function. It has a different name, no docstring,
and a parameter list of `*args, **kwargs`.

Nothing has depended on that yet. It starts mattering as soon as
anything looks at your function rather than calling it: documentation
tools, debuggers, test frameworks, and you, reading a traceback at the
wrong moment.

**Preserving the wrapped function** is next, and it is short.

Press Finish below to move on.
