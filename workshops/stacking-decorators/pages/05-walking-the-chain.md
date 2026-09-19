---
title: Walking the chain
requires: [verify:chain-walk]
---

# Walking the chain

A stack of three decorators is four objects: three wrappers and the
function. When something misbehaves you often want the one at the
bottom, and `__wrapped__` is the thread that leads there, one link per
decorator that used `functools.wraps`.

One tidy stack and one with a careless decorator in the middle, the kind
that forgets `wraps`.

```{cell-insert}
:id: insert-chain
:path: {{ notebook }}
:tags: [chain]
:run: true
def careless(func):
    def wrapper(*args, **kwargs):
        return func(*args, **kwargs)
    return wrapper

@bold
@italic
def tidy():
    """the real one"""
    return "hi"

@bold
@careless
def broken():
    """the real one"""
    return "hi"

def layers(fn):
    names = []
    while fn is not None:
        names.append(fn.__name__)
        fn = getattr(fn, "__wrapped__", None)
    return names

print("tidy   :", layers(tidy))
print("broken :", layers(broken))
print("tidy docstring   :", inspect.unwrap(tidy).__doc__)
print("broken docstring :", inspect.unwrap(broken).__doc__)
```

The tidy stack gives a chain the whole way down, and every link reports
the same name, `tidy`, because that is what `wraps` copied. You cannot
tell the layers apart by name, only count them.

The broken stack stops early. `careless` returned a wrapper with no
`__wrapped__`, so the thread is cut there: the walk ends at an anonymous
`wrapper`, and `inspect.unwrap` gets no further either. The docstring
comes back as `None`, because the only thing that still knows it is on
the other side of the break.

`inspect.unwrap` is the right way to do this in real code rather than
the loop above, and it follows the same links.

The practical consequence is that one careless decorator poisons
everything stacked above it. Your own decorators can be perfect, and if
a library's decorator sits underneath and omits `wraps`, the function
still reports itself as `wrapper` with no docstring and no signature.
That is the argument for `wraps` being automatic rather than
considered: you are not only protecting your own decorator, you are
protecting every stack yours ends up in.

```{verify}
:id: chain-walk
:label: The tidy chain reaches the original and the broken one does not
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed chain
len(layers(tidy)) == 3 and layers(broken) == ["wrapper", "wrapper"] and inspect.unwrap(tidy).__doc__ == "the real one" and inspect.unwrap(broken).__doc__ is None
```
