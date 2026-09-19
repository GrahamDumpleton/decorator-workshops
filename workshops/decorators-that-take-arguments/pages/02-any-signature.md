---
title: Any signature at all
requires: [verify:forwarding-works]
---

# Any signature at all

Put that same decorator on a function that takes two arguments and it
falls apart.

```{cell-insert}
:id: insert-broken
:path: {{ notebook }}
:tags: [broken]
:run: true
@announce
def add(a, b):
    return a + b

try:
    add(2, 3)
    problem = "no error"
except TypeError as error:
    problem = str(error)

print(problem)
```

The error is about `wrapper`, not about `add`. `add` never ran. The
wrapper is the thing being called, so its parameter list is the one that
has to fit, and it was written for exactly one argument named `name`.

A decorator cannot know what it will be used on, so the wrapper must
accept anything and pass it along unexamined. `*args` collects any
positional arguments into a tuple and `**kwargs` collects any keyword
arguments into a dictionary. Using them again at the call site spreads
them back out.

```{cell-insert}
:id: insert-forwarding
:path: {{ notebook }}
:tags: [forwarding]
:run: true
def announce(func):
    def wrapper(*args, **kwargs):
        print(f"calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@announce
def add(a, b=10):
    return a + b

results = [add(2, 3), add(2), add(a=1, b=2)]
print("results:", results)
```

`[5, 12, 3]`. Three different calling styles, and the wrapper did not
have to know about any of them. It never looks inside `args` or
`kwargs`; it just hands them on.

Two details in that wrapper are worth naming, because leaving either out
produces a bug that is hard to see:

- `func(*args, **kwargs)`, with the stars, spreads the collection back
  into separate arguments. Writing `func(args, kwargs)` would pass the
  tuple and the dictionary as two single arguments instead.

- `return` in front of it. Without it the wrapper returns `None` and
  every decorated function in your program silently stops giving
  answers.

```{verify}
:id: forwarding-works
:label: The wrapper forwards positional and keyword arguments
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed forwarding
results == [5, 12, 3] and "positional" in problem
```

```{hint}
:title: Why not copy the real signature
Because then the decorator would only work on functions shaped like that
one, which is the problem you just fixed. `*args, **kwargs` is the price
of a decorator that fits everything. It has a cost, which the next
workshop is about: tools that read the wrapper see those stars rather
than the real parameters.
```
