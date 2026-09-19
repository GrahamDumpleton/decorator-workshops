---
title: The extra layer
requires: [verify:repeat-works]
---

# The extra layer

Now the second problem. Try to pass the decorator a setting.

```{cell-insert}
:id: insert-with-setting
:path: {{ notebook }}
:tags: [with-setting]
:run: true
try:
    @announce("loudly")
    def hello():
        return "hi"

    problem = "no error"
except Exception as error:
    problem = f"{type(error).__name__}: {error}"

print(problem)
```

`AttributeError: 'str' object has no attribute '__name__'`. Probably not
the error you would have predicted, and following it is the quickest way
to see what `@` actually does.

`@` takes whatever is to its right and calls it with the function
underneath. Here that is `announce("loudly")`, which runs first and
succeeds: it returns a wrapper exactly as it always does, holding
`"loudly"` as its `func`. Nothing has gone wrong yet.

Python then applies that wrapper to `hello`, which runs the wrapper's
body, and the first thing the body does is read `func.__name__`. Strings
do not have one. Had the wrapper called `func` straight away instead,
the same mistake would have surfaced as `TypeError: 'str' object is not
callable`. Either way, a string ended up where a function belonged.

So `@announce` and `@announce("loudly")` are genuinely different. The
first hands `announce` the function. The second calls `announce` and
hands the *result* the function.

That is what the extra layer is for. Three nested functions, each with
one job:

- the outer one takes the settings and returns the decorator,

- the decorator takes the function and returns the wrapper,

- the wrapper takes the call's arguments and does the work.

```{cell-insert}
:id: insert-repeat
:path: {{ notebook }}
:tags: [repeat]
:run: true
def repeat(times):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator

calls = []

@repeat(3)
def ping():
    calls.append(1)
    return len(calls)

print("returned:", ping())
print("times called:", len(calls))
```

One `ping()` ran the body three times. `@repeat(3)` called `repeat` with
3 straight away, which returned `decorator`, which was then applied to
`ping` exactly as a plain decorator would be.

Each layer can see the layer above it, so `wrapper` reads `times`
without anyone passing it down. That is the closure from workshop three,
doing the work that makes this shape possible at all.

```{verify}
:id: repeat-works
:label: repeat(3) runs the function three times
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed repeat
len(calls) == 3 and "AttributeError" in problem
```

```{hint}
:title: Counting the layers
A plain decorator has two `def`s. A configurable one has three. If you
are ever unsure which you are looking at, count them, then check the
bottom one takes `*args, **kwargs` and the top one takes your settings.
```
