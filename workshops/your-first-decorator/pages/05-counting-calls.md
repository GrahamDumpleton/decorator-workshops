---
title: Counting calls
requires: [verify:count-works]
---

# Counting calls

So far each wrapper has done its work and forgotten about it. This one
keeps a running total, which means it needs somewhere to put the count.

The trick is that `wrapper` is an object like any other function, so you
can hang an attribute on it. Set it to zero before returning the
wrapper, and add one on every call.

```{cell-insert}
:id: insert-count
:path: {{ notebook }}
:tags: [count]
:run: true
def count_calls(func):
    def wrapper(*args, **kwargs):
        wrapper.call_count += 1
        return func(*args, **kwargs)

    wrapper.call_count = 0
    return wrapper

@count_calls
def ping():
    return "pong"

ping()
ping()
ping()

ping.call_count
```

Three calls, and `ping.call_count` is 3.

Look at what that expression means. `ping` is the wrapper, so
`ping.call_count` is the attribute set inside `count_calls`. The
decorator has given the decorated function a new piece of public
interface that the original never had, which is exactly what
`@functools.cache` did when it gave you `cache_info`.

Decorate a second function and each gets its own count, because each
call to `count_calls` builds a separate `wrapper` object with its own
attribute.

```{cell-insert}
:id: insert-separate
:path: {{ notebook }}
:tags: [separate]
:run: true
@count_calls
def pong():
    return "ping"

pong()

print("ping:", ping.call_count)
print("pong:", pong.call_count)
```

```{verify}
:id: count-works
:label: Each decorated function counts its own calls
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed separate
ping.call_count == 3 and pong.call_count == 1
```

```{hint}
:title: Why the count survives between calls
`wrapper.call_count` is an attribute on an object that stays alive for
as long as the name `ping` points at it, so it persists between calls
the way any attribute does. There is a second way to keep state here,
using a variable rather than an attribute, and it needs one keyword you
have not met yet. The next workshop covers it.
```
