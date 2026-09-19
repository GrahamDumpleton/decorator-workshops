---
title: The pitfall in a loop
requires: [quiz:predict-loop, verify:late-binding-fixed]
---

# The pitfall in a loop

Now the bug that catches everyone once, and catches people who write
decorators more often than most, because building functions in a loop is
what decorator factories and registries do.

Three functions are built in a loop. Each one returns `i`. Before you
run it, commit to an answer.

```python
makers = []
for i in range(3):
    makers.append(lambda: i)

[make() for make in makers]
```

```{quiz}
:id: predict-loop
:title: Predict the result
:shuffle: true
question: "What does that last line produce?"
options:
  - text: "[2, 2, 2]"
    correct: true
  - text: "[0, 1, 2]"
    explanation: "That is what almost everyone expects, and what you get only if each function captures the value of i at the time it was built. They do not."
  - text: "A NameError, because i is gone after the loop."
    explanation: "The cell keeps i alive, so there is no NameError. The question is what value it holds."
  - text: "[0, 0, 0]"
    explanation: "The functions share one cell rather than each getting the first value. They all see whatever that cell holds when they are called."
explanation: "A closure captures the variable, not its value. All three functions share one cell holding i, and by the time any of them runs, the loop has finished and left 2 in it."
```

Now run it.

```{cell-insert}
:id: insert-late
:path: {{ notebook }}
:tags: [late]
:run: true
makers = []
for i in range(3):
    makers.append(lambda: i)

results = [make() for make in makers]
results
```

`[2, 2, 2]`. The three functions are not broken and they are not
sharing a bug: they are sharing a cell. `i` is one variable belonging to
the enclosing scope, the loop reassigned it on each pass, and none of
the functions read it until the loop was over and it held 2.

This is called late binding, and it follows from what you saw on page
two. A closure holds a cell, not a value. Read it later and you get what
is in it later.

The fix is to capture the value at the moment the function is built, and
the plainest way is a default argument, which is evaluated once when the
`def` or `lambda` runs.

```{cell-insert}
:id: insert-fixed
:path: {{ notebook }}
:tags: [fixed]
:run: true
fixed = []
for i in range(3):
    fixed.append(lambda i=i: i)

fixed_results = [make() for make in fixed]
fixed_results
```

`[0, 1, 2]`. `lambda i=i: i` reads oddly the first time: the `i` on the
right is the loop variable, evaluated now, and the `i` on the left is a
parameter with that as its default. The function no longer borrows
anything from the enclosing scope, so there is no cell and nothing to go
stale.

```{verify}
:id: late-binding-fixed
:label: Late binding reproduced, then fixed
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed fixed
results == [2, 2, 2] and fixed_results == [0, 1, 2]
```

```{hint}
:title: The other fix
A factory function. `make_multiplier(2)` on page three had no such
problem, because each call gave `n` a fresh cell of its own. Calling a
function to build each one is the same idea as the default argument:
bind the value now, not later.
```
