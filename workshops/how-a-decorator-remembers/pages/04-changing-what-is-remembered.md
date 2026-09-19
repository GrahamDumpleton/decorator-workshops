---
title: Changing what is remembered
requires: [verify:counter-counts]
---

# Changing what is remembered

Reading a remembered value is one thing. Changing it needs a keyword,
and the reason why is worth understanding.

Assigning to a name inside a function makes that name local to the
function, everywhere in it. So an inner function that does `count += 1`
is read as "read local `count`, add one, store local `count`", and the
read happens before anything was ever stored. Watch it fail.

```{cell-insert}
:id: insert-broken
:path: {{ notebook }}
:tags: [broken]
:run: true
def broken_counter():
    count = 0

    def increment():
        count += 1
        return count

    return increment

try:
    broken_counter()()
    error = "no error"
except UnboundLocalError as exc:
    error = str(exc)

error
```

`UnboundLocalError`. The enclosing `count` is right there, and Python
will not use it, because the assignment made `count` local to
`increment`.

`nonlocal` says: this name belongs to the enclosing function, so read
and write it there.

```{cell-insert}
:id: insert-counter
:path: {{ notebook }}
:tags: [counter]
:run: true
def make_counter():
    count = 0

    def increment():
        nonlocal count
        count += 1
        return count

    return increment

counter = make_counter()
values = [counter(), counter(), counter()]
values
```

`[1, 2, 3]`. The value in the cell is being updated, and it survives
between calls because the cell does.

This is the second way to keep state in a decorator. The last workshop
used `wrapper.call_count`, an attribute on the wrapper object.
`nonlocal` uses a variable in the enclosing scope instead. Both work,
and they differ in one visible way: the attribute is public, so
`ping.call_count` can be read from outside, while a `nonlocal` variable
is reachable only through the functions that close over it.

```{verify}
:id: counter-counts
:label: The counter counts, and the version without nonlocal fails
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed counter
values == [1, 2, 3] and error != "no error"
```

```{hint}
:title: Why reading worked without nonlocal
Because reading a name never makes it local. `multiply` on the last page
only read `n`, so Python looked outwards and found it. The moment a
function assigns to a name anywhere in its body, that name is local
throughout, and `nonlocal` is how you say you meant the outer one.
```
