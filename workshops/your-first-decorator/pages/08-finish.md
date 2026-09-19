---
title: What you know now
requires: [quiz:what-is-ping]
---

# What you know now

You have written five decorators, and found out along the way what the
first four were missing. This is the shape they ended up at, and the one
to start from next time:

```python
def decorator(func):
    def wrapper(*args, **kwargs):
        # before the call
        try:
            result = func(*args, **kwargs)
        finally:
            # after it, whether it returned or raised
            pass
        return result
    return wrapper
```

A function that takes a function, defines a replacement, and returns it.
`*args, **kwargs` so the replacement fits any signature, and
`return result` so nothing is swallowed. The `try`/`finally` is the part
that came last: reach for it when the work after the call has to happen
even if the call fails, and leave it out when that work only makes sense
for a call that succeeded.

Between them, those five logged calls, timed them, counted them, stopped
one from happening, and kept a timer honest about a function that
raised. You also saw that `@decorator` above a `def` is shorthand for
`name = decorator(name)`, and confirmed it by writing both forms.

```{quiz}
:id: what-is-ping
:title: What the name points at
:shuffle: true
question: "After `@count_calls` above `def ping():`, what is the name `ping` bound to?"
options:
  - text: "The wrapper function that count_calls returned."
    correct: true
  - text: "The original ping function, with counting switched on."
    explanation: "The original function is unchanged and no longer has a name of its own. The only thing holding it is the wrapper, which calls it."
  - text: "The count_calls function."
    explanation: "count_calls ran once, at definition time, and returned the wrapper. It is the return value that the name is bound to, not count_calls itself."
  - text: "A special decorated-function object that Python creates."
    explanation: "There is no such object. The wrapper is an ordinary function, which is why you can set an attribute like call_count on it."
explanation: "ping = count_calls(ping), so ping is whatever count_calls returned: the wrapper. That is why ping.call_count works and why ping.__name__ says wrapper."
```

## The question this leaves open

Look again at `count_calls`. It ran once, returned `wrapper`, and
finished. Its local variable `func` should have gone when it returned,
the way locals normally do.

Yet every time you call `ping`, the wrapper reaches for `func` and finds
it, minutes later, long after `count_calls` is done.

Something is keeping it alive. The next workshop, **How a decorator
remembers**, shows you what, and lets you look at it directly.

Press Finish below to move on.
