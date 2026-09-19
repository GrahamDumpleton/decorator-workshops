---
title: The cell that holds it
requires: [verify:closure-holds-greet]
---

# The cell that holds it

When Python compiles `wrapper` it notices something: the body mentions
`func`, which is not a local of `wrapper` and not a global either. It
belongs to the function `wrapper` was defined inside.

A function with a name like that is called a closure, and Python
attaches the values it needs to the function object itself. Ask for
them.

```{cell-insert}
:id: insert-closure
:path: {{ notebook }}
:tags: [closure]
:run: true
decorated.__closure__
```

A tuple with one cell in it. A cell is a small box holding one value,
and this is where the answer to the puzzle lives. Open it.

```{cell-insert}
:id: insert-contents
:path: {{ notebook }}
:tags: [contents]
:run: true
cell = decorated.__closure__[0]

print("free variables:", decorated.__code__.co_freevars)
print("cell contents: ", cell.cell_contents)
print("is it greet?  ", cell.cell_contents is greet)
```

`co_freevars` names what the wrapper borrows from its enclosing scope,
which is `func`. The cell holds the value, and it is not a copy of
`greet` or something that looks like it: it is `greet`, the very same
object.

So `logging_wrapper` did return, and its frame did go. But `func` was
never only in that frame. It was in a cell, and the cell is attached to
`wrapper`, which is still very much alive because `decorated` points at
it. Keeping the wrapper keeps the cell, and keeping the cell keeps the
original function.

```{verify}
:id: closure-holds-greet
:label: The closure cell holds the original function
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed closure; cell-executed contents
decorated.__closure__[0].cell_contents is greet
```

```{hint}
:title: This is why the original never gets lost
When you write `greet = logging_wrapper(greet)`, the name `greet` stops
pointing at the original function. Nothing else refers to it by name.
The only reason it is not garbage collected is the cell, which is also
the only route the wrapper has to call it.
```
