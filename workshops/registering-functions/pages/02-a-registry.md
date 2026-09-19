---
title: A registry
requires: [verify:same-object]
---

# A registry

Register two commands and then look carefully at what happened to them.

```{cell-insert}
:id: insert-register
:path: {{ notebook }}
:tags: [register]
:run: true
@command("greet")
def do_greet(who):
    return f"hello {who}"

@command("shout")
def do_shout(who):
    return f"HELLO {who.upper()}"

print("registered:", list(commands))
print("called directly:", do_greet("world"))
print("same object?", commands["greet"] is do_greet)
print("__name__ :", do_greet.__name__)
```

`commands["greet"] is do_greet` is `True`. Not an equal object, the same
object. There is no wrapper anywhere, `functools.wraps` is not needed
and would have nothing to do, and `do_greet.__name__` is right because
nothing ever replaced it.

This is worth dwelling on because it separates two words that are easy
to run together. A **decorator** is anything that runs at definition
time and decides what the name ends up bound to. A **wrapper** is one
thing a decorator might return. Most decorators return a wrapper; this
one returns the original, having used its turn for a side effect
instead.

Now the registry is useful: a dispatcher can look a command up by name,
which is something a plain function definition cannot offer.

```{cell-insert}
:id: insert-dispatch
:path: {{ notebook }}
:tags: [dispatch]
:run: true
def dispatch(name, *args):
    handler = commands.get(name)
    if handler is None:
        return f"unknown command: {name}"
    return handler(*args)

print(dispatch("greet", "ada"))
print(dispatch("shout", "ada"))
print(dispatch("dance", "ada"))
```

The point is where the knowledge lives. Without the decorator you would
write the functions and then, somewhere else, a dictionary listing them,
and the two would drift apart the first time someone added a command and
forgot the second half. The decorator puts the registration on the
function itself, where it cannot be forgotten and can be seen by anyone
reading the definition.

```{verify}
:id: same-object
:label: The registry holds the original function, unchanged
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed dispatch
commands["greet"] is do_greet and do_greet.__name__ == "do_greet" and dispatch("greet", "ada") == "hello ada"
```
