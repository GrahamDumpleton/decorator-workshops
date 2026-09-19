---
title: Timing a call
requires: [verify:timer-works]
---

# Timing a call

Logging was a warm-up. The same shape gives you something you will
actually reach for: a decorator that says how long a call took.

The only difference from `logging_wrapper` is what happens around the
call. Read the middle three lines: note the time, call the function,
note the time again.

```{cell-insert}
:id: insert-timer
:path: {{ notebook }}
:tags: [timer]
:run: true
import time

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__} took {elapsed:.3f}s")
        return result
    return wrapper

@timer
def slow_add(a, b):
    time.sleep(0.05)
    return a + b

total = slow_add(2, 3)
print("result:", total)
```

`slow_add` still returns 5, and still knows nothing about being timed.
Put `@timer` above any other function and it is timed too, with no
further work.

Use `time.perf_counter` rather than `time.time` for this. It is meant
for measuring intervals and cannot jump backwards when the system clock
is adjusted.

```{verify}
:id: timer-works
:label: The timed function still returns its result
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed timer
total == 5
```

```{hint}
:title: Why the decorator is a good place for this
Because timing is not what `slow_add` is about. Written inside the
function, the timing code is mixed into the logic, has to be repeated
for every function you care about, and has to be deleted again when you
stop caring. As a decorator it is one line above the `def`, and
removing it removes the timing completely.
```
