---
title: The @ syntax
requires: [verify:at-syntax-works]
---

# The @ syntax

The reassignment you just wrote works, but it has a flaw: it sits below
the function, sometimes a long way below. Someone reading `greet` from
the top has no idea it is wrapped until they reach that line.

`@` moves it to the top. Define `greet` again, decorated this time, and
compare what happens.

```{cell-insert}
:id: insert-at-syntax
:path: {{ notebook }}
:tags: [at-syntax]
:run: true
@logging_wrapper
def greet(name):
    return f"Hello, {name}!"

result = greet("Bob")
```

Identical output, and `greet.__name__` is still `wrapper`, because
exactly the same thing happened. These two are the same code:

```python
@logging_wrapper
def greet(name):
    ...

# and

def greet(name):
    ...
greet = logging_wrapper(greet)
```

No new mechanism, no interpreter magic, nothing that only works with
`@`. It is a place to write the reassignment, chosen so that the reader
sees it first.

That is also why a decorator can be any callable that takes one
argument and returns something: Python does not check what
`logging_wrapper` is, it just calls it and binds the result.

```{verify}
:id: at-syntax-works
:label: The decorated greet behaves the same as the hand-wrapped one
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed at-syntax
result == "Hello, Bob!" and greet.__name__ == "wrapper"
```
