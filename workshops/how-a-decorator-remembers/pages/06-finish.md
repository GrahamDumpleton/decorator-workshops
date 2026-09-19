---
title: What you know now
requires: [quiz:why-func-survives]
---

# What you know now

The puzzle is solved. When a decorator returns its wrapper, the wrapper
carries a closure: one cell per borrowed name, attached to the function
object itself. `func` is in a cell, the cell lives as long as the
wrapper does, and that is how a decorated function still knows what it
decorated.

Along the way you saw that:

- `__closure__` is `None` for a function that borrows nothing, and a
  tuple of cells for one that does. `__code__.co_freevars` names them.

- Each call to a factory builds fresh cells, which is why two decorated
  functions keep separate counts.

- `nonlocal` is needed to assign to a borrowed name, because assigning
  to a name anywhere in a function makes it local throughout.

- A closure captures the variable, not the value, so functions built in
  a loop all see the loop variable's final value unless you bind it at
  build time.

```{quiz}
:id: why-func-survives
:title: Why the original survives
:shuffle: true
question: "A decorator has returned. What keeps the original function alive?"
options:
  - text: "A cell attached to the wrapper, holding it, kept alive as long as the wrapper is."
    correct: true
  - text: "The decorator's frame, which Python keeps until the wrapper is discarded."
    explanation: "The frame is gone as soon as the decorator returns, like any other call. Only the cells outlive it."
  - text: "A reference in the wrapper's __dict__, set when the wrapper was defined."
    explanation: "Nothing is stored in __dict__ unless you put it there, as count_calls did with call_count. The closure is a separate mechanism."
  - text: "Nothing does; Python looks the original up by name when the wrapper runs."
    explanation: "There is no name left to look up. After `greet = decorator(greet)` the original has no name at all, only the cell."
explanation: "The wrapper's __closure__ holds a cell containing the original function, so as long as something refers to the wrapper, the original cannot be collected."
```

## Where this goes next

You can now write a decorator and explain why it works. The next step is
decorators you can configure, like `@repeat(3)` or
`@retry(max_attempts=5)`, where the decorator itself takes arguments.

That needs one more layer of nesting than seems reasonable, and the
reason is exactly what this workshop was about: each layer is a scope,
and each scope is something the innermost function can remember.
**Decorators that take arguments** is next.

Press Finish below to move on.
