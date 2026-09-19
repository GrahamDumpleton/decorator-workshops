---
title: Functions that make functions
requires: [verify:multipliers-differ]
---

# Functions that make functions

Decorators are one use of closures. The general case is a function that
builds a function to order, and it is worth seeing on its own, away from
any `@`.

`make_multiplier` takes a number and returns a function that multiplies
by it. Call it twice with different numbers and you get two different
functions.

```{cell-insert}
:id: insert-multiplier
:path: {{ notebook }}
:tags: [multiplier]
:run: true
def make_multiplier(n):
    def multiply(x):
        return x * n
    return multiply

double = make_multiplier(2)
triple = make_multiplier(3)

print(double(21), triple(21))
print("double remembers:", double.__closure__[0].cell_contents)
print("triple remembers:", triple.__closure__[0].cell_contents)
```

The same two lines of source produced two functions that behave
differently, because each has its own cell holding its own `n`. The code
is shared; the remembered values are not.

That is precisely what happened when you decorated two functions in the
last workshop and each kept its own `call_count`. Every call to the
decorator builds a fresh wrapper with a fresh set of cells.

A function that borrows nothing has no closure at all.

```{cell-insert}
:id: insert-no-closure
:path: {{ notebook }}
:tags: [no-closure]
:run: true
def plain(x):
    return x * 2

print(plain.__closure__)
```

`None`, not an empty tuple. `plain` mentions only its own argument, so
there is nothing to carry and Python attaches nothing. Closures are not
something functions have in general: they appear exactly when an inner
function uses a name from the scope around it.

That one is printed rather than left as the cell's last line, because a
notebook shows no output at all when the result is `None`. Written as a
bare `plain.__closure__` the cell would look as though it had failed to
run. Worth knowing the first time it puzzles you.

```{verify}
:id: multipliers-differ
:label: The two multipliers remember different numbers
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed no-closure
double(21) == 42 and triple(21) == 63 and plain.__closure__ is None
```
