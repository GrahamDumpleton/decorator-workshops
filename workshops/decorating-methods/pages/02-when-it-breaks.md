---
title: When it breaks
requires: [verify:it-breaks]
---

# When it breaks

Now the same idea written as a class. `CountCalls` takes the function in
`__init__` and does the work in `__call__`, which makes an instance of
it callable, and callable is all a decorator has to be.

On a plain function this works perfectly. On a method it does not.

```{cell-insert}
:id: insert-breaks
:path: {{ notebook }}
:tags: [breaks]
:run: true
class CountCalls:
    def __init__(self, func):
        self.func = func
        self.count = 0

    def __call__(self, *args, **kwargs):
        self.count += 1
        return self.func(*args, **kwargs)

class Broken:
    def __init__(self, name):
        self.name = name

    @CountCalls
    def sell(self, item):
        return f"{self.name} sold {item}"

broken = Broken("Corner Store")

try:
    broken.sell("hat")
    problem = "no error"
except TypeError as error:
    problem = str(error)

print("Broken.sell is a:", type(Broken.sell).__name__)
print("problem:", problem)
```

Read the error carefully, because it is not the one people quote.

It says `sell()` is missing `item`, not missing `self`. `item` was the
argument you passed. Understanding why it is the one reported is
understanding the whole problem.

`Broken.sell` is a `CountCalls` instance rather than a function, and
that is the difference that matters. When you write `broken.sell`,
Python asks the class attribute to bind itself to the instance.
Functions know how to do that, which is how `self` normally gets
supplied, and it is why the `timer` version worked: a function decorator
returns a function, so binding still happens.

A `CountCalls` instance does not know how to bind. So `broken.sell` is
just the instance itself, with no memory of `broken`, and calling it
passes only `("hat",)`. Inside, `self.func(*args)` calls the original
`sell` with one argument, which lands in its first parameter, `self`.
The instance never arrived, every argument shifted along by one, and
`item` fell off the end.

```{verify}
:id: it-breaks
:label: The class-based decorator broke the method
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed breaks
type(Broken.sell).__name__ == "CountCalls" and "missing 1 required positional argument" in problem
```

```{hint}
:title: The name for what is missing
Binding is done through the descriptor protocol: an object with a
`__get__` method gets a say in what happens when it is looked up on an
instance, and functions have one. A class-based decorator can implement
`__get__` too, which is exactly how you fix this. **How methods bind**,
two workshops from here, is where you do it.
```
