---
title: What it copies, and what is left
requires: [verify:the-residue]
---

# What it copies, and what is left

`wraps` is not magic either. It has a list, and you can read it.

```{cell-insert}
:id: insert-lists
:path: {{ notebook }}
:tags: [lists]
:run: true
print("copied outright:")
for name in functools.WRAPPER_ASSIGNMENTS:
    print("   ", name)

print("merged in:", functools.WRAPPER_UPDATES)
```

`WRAPPER_ASSIGNMENTS` is assigned straight across.
`WRAPPER_UPDATES` is merged rather than replaced, and it holds
`__dict__`, the function's own attribute dictionary. That is how
anything else attached to a function survives decoration.

```{cell-insert}
:id: insert-attributes
:path: {{ notebook }}
:tags: [attributes]
:run: true
def original():
    return 1

original.role = "admin"

decorated = logged(original)

print("role survived:", decorated.role)
```

That matters more than it looks. Frameworks mark functions by hanging
attributes on them, a route path, a permission, a test marker, and a
decorator that did not copy `__dict__` would quietly drop the mark and
leave you with a route nobody serves.

Now the part `wraps` genuinely cannot fix. It restored what your
function *says* it is. It did not change what the wrapper *is*.

```{cell-insert}
:id: insert-residue
:path: {{ notebook }}
:tags: [residue]
:run: true
print("as tools see it   :", inspect.signature(greet))
print("as the wrapper is :", inspect.signature(greet, follow_wrapped=False))

try:
    greet("a", "b", "c")
    arity = "no error"
except TypeError as error:
    arity = str(error)

print("a wrong call      :", arity)
```

Ask `inspect` not to follow the link and the truth comes back:
`(*args, **kwargs)`. Any tool that reads the wrapper directly rather
than following `__wrapped__` sees that, and so does the interpreter.

Which is why the last line matters. The wrapper accepted a call with
three arguments quite happily, because `*args` accepts anything. The
`TypeError` came from `greet` itself, one frame further in, once the
wrapper passed the call along. The message is good and the error is
correct, but it was raised a step later than you might expect, and the
traceback has a `wrapper` frame in it.

```{verify}
:id: the-residue
:label: The attribute survived and the wrapper's own signature is unchanged
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed residue
decorated.role == "admin" and str(inspect.signature(greet, follow_wrapped=False)) == "(*args, **kwargs)" and "positional argument" in arity
```
