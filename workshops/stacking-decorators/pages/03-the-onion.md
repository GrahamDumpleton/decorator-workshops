---
title: The onion
requires: [verify:onion-order]
---

# The onion

The tags showed you the result. This shows you the journey, which is
where the second order appears.

`trace` records when it is entered and when it is left, so a stack of
two writes down exactly what happened and in what order.

```{cell-insert}
:id: insert-trace
:path: {{ notebook }}
:tags: [trace]
:run: true
order = []

def trace(label):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            order.append(f"enter {label}")
            result = func(*args, **kwargs)
            order.append(f"exit {label}")
            return result
        return wrapper
    return decorator

@trace("outer")
@trace("inner")
def work():
    order.append("body")
    return "done"

work()

for step in order:
    print(step)
```

```
enter outer
enter inner
body
exit inner
exit outer
```

That is one call, passing through both wrappers on the way in and both
again on the way out. The shape is an onion: outer, inner, the function,
inner, outer.

Now hold the two orders side by side, because this is the whole lesson:

- **Applied bottom to top.** `trace("inner")` was applied first, at
  definition time, and `trace("outer")` was applied to the result.

- **Run top to bottom.** On every call, `outer` runs first, because it
  is the outermost wrapper and therefore the one the name points at.

They are opposites, and neither is arbitrary. The decorator applied last
ends up outermost, and the outermost wrapper is the first one a call
reaches. Say it once that way round and the confusion tends not to come
back.

It also tells you where to put a decorator. Anything that should see the
call before anything else happens, an authentication check, a rate
limit, a circuit breaker, goes at the top. Anything that should sit
closest to the real work, a cache or a timer, goes at the bottom.

```{verify}
:id: onion-order
:label: The call went in through both wrappers and back out
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed trace
order == ["enter outer", "enter inner", "body", "exit inner", "exit outer"]
```
