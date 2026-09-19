---
title: What you know now
requires: [quiz:what-is-returned]
---

# What you know now

The whole pattern is three lines:

```python
def register(name):
    def decorator(func):
        registry[name] = func
        return func
    return decorator
```

Store the function, return it unchanged. The decoration is a side effect
and the function itself is untouched, which is why it needs no
`functools.wraps`, keeps its own name, and can still be called directly.

From that one shape you built a command dispatcher, a route table and an
event system. They differ only in what the registry maps to: one
function, one function per path, or a list of functions per event.

The value is that the registration lives on the definition rather than
in a separate list that drifts out of date. The cost is that reading the
code at the point something is emitted tells you nothing about what will
happen, and a module that is never imported is never registered.

```{quiz}
:id: what-is-returned
:title: What comes back
:shuffle: true
question: "After `@command(\"greet\")` above `def do_greet(who)`, what is the name `do_greet` bound to?"
options:
  - text: "The original function, exactly as written."
    correct: true
  - text: "A wrapper that looks the function up in the registry and calls it."
    explanation: "Nothing wraps it. The decorator's inner function returns `func` itself, so the name ends up bound to what it was already."
  - text: "The registry entry, so calling it performs a lookup."
    explanation: "The registry holds a reference to the function; the name is not rebound to the registry. `commands[\"greet\"] is do_greet` is True precisely because they are the same object."
  - text: "None, because the decorator has no return statement for the function."
    explanation: "It does return: `return func` is the last line of the inner decorator. Leaving it out is a real and common bug, and would bind the name to None."
explanation: "The decorator stores the function and returns it, so the name is bound to the original. That is what makes this pattern different from every other decorator in the collection."
```

## Where this goes next

That was the decorator that changes nothing. The next one changes a
great deal: it catches what the function raised, decides whether the
failure is worth another attempt, and writes down what happened.

You will also see the ordering lesson from workshop six pay off for
real. Stack logging above retrying and you get one log line per failed
call; stack it below and you get one per attempt. Both are defensible
and you should choose rather than discover.

**Retrying and handling errors** is next.

Press Finish below to move on.
