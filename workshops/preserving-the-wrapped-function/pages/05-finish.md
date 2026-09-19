---
title: What you know now
requires: [quiz:what-wraps-does]
---

# What you know now

Put `@functools.wraps(func)` on every wrapper you write. That is the
whole practical lesson, and it is one line:

```python
def decorator(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper
```

Without it, a decorated function reports itself as `wrapper`, with no
docstring and a signature of `(*args, **kwargs)`, and nothing can find
its way back to the original.

With it, the name, docstring and module are copied, the function's own
attributes are merged across, and `__wrapped__` points at the original,
which is what lets `inspect` report the real signature and the real
source.

What is left over is small but worth knowing: the wrapper's own
signature is still `(*args, **kwargs)`, visible to anything that does
not follow `__wrapped__`, and a call with the wrong arguments fails one
frame further in than it would have without the decorator.

```{quiz}
:id: what-wraps-does
:title: How the signature comes back
:shuffle: true
question: "With `@functools.wraps`, why does `inspect.signature()` report the original function's parameters?"
options:
  - text: "Because wraps sets `__wrapped__`, and inspect follows it to the original."
    correct: true
  - text: "Because wraps rewrites the wrapper to have the same parameters."
    explanation: "Nothing rewrites the wrapper. Ask with `follow_wrapped=False` and you still get `(*args, **kwargs)`, because that is genuinely what the wrapper takes."
  - text: "Because `__signature__` is one of the attributes in WRAPPER_ASSIGNMENTS."
    explanation: "It is not in the list, which holds `__module__`, `__name__`, `__qualname__`, `__doc__` and a couple of others. The signature comes from following `__wrapped__`, not from a copied attribute."
  - text: "Because the wrapper delegates unknown attribute lookups to the original."
    explanation: "A plain function does no such delegation. That is what a proxy object would do, and writing one is a different technique entirely."
explanation: "wraps sets `__wrapped__` on the wrapper. inspect.signature and inspect.getsource follow that link, so they answer about the function you meant."
```

## Where this goes next

So far one decorator has gone on one function. Next, several go on the
same function, and two different kinds of order appear: the order they
are applied in, and the order they run in. They are not the same order,
which is where the confusion usually starts.

**Stacking decorators** is next.

Press Finish below to move on.
