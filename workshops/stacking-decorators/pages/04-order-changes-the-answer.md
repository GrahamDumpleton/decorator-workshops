---
title: When the order changes the answer
requires: [verify:counts-differ]
---

# When the order changes the answer

With `bold` and `italic` the order changed the output, which was
obvious. Here it changes a number you might report to someone, which is
not obvious at all, and both stacks are correct.

A counter and a cache, one each way round. Every call asks for the same
item three times.

```{cell-insert}
:id: insert-counts
:path: {{ notebook }}
:tags: [counts]
:run: true
counts = {"under": 0, "above": 0}

def count_calls(label):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            counts[label] += 1
            return func(*args, **kwargs)
        return wrapper
    return decorator

@functools.cache
@count_calls("under")
def price_under(item):
    return len(item) * 10

@count_calls("above")
@functools.cache
def price_above(item):
    return len(item) * 10

for _ in range(3):
    price_under("widget")
    price_above("widget")

print("counted under the cache:", counts["under"])
print("counted above the cache:", counts["above"])
```

One and three, from the same two decorators and the same three calls.

Under the cache, the counter only sees calls the cache could not answer,
so it counts work actually done. Above the cache, the counter sees every
call before the cache gets a chance, so it counts demand.

Neither is a bug. They answer different questions, and the stack is
where you choose which question you are asking. "How expensive is this
function?" wants the counter underneath. "How popular is this endpoint?"
wants it on top. Getting it the wrong way round gives you a number that
looks plausible and means something else, which is worse than an error.

```{verify}
:id: counts-differ
:label: The two stacks counted different things
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed counts
counts["under"] == 1 and counts["above"] == 3
```

```{hint}
:title: Why the count lives in a dictionary here
Because keeping it on the wrapper, as `wrapper.call_count` did in
workshop two, goes wrong in a stack. `functools.wraps` merges the
wrapped function's `__dict__` into the wrapper, so an outer decorator
copies the inner one's `call_count` at the moment of decoration and then
reports that stale snapshot for ever, while the real count climbs on the
wrapper underneath. A counter shared through an enclosing scope, as
here, has no such problem.
```
