---
title: Welcome
requires: [verify:greet-works]
---

# Your first decorator

A decorator is a function that takes a function and gives back a
replacement for it. That is the whole idea. Everything else is detail.

In this workshop you write that function. First by hand, with no `@`
anywhere, so there is nothing to take on trust. Then with `@`, and you
confirm the two are identical.

If you have not met the `@` line before, it is shorthand:
`@shout` above `def greet(...)` means "define `greet`, pass it to
`shout`, and bind the name `greet` to whatever `shout` returns".

The step below creates the notebook with the function you will be
decorating. It is deliberately dull: one line, no surprises, so that
every change you see later comes from the decorator and not from the
function.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Your first decorator
    Each step of the workshop adds a cell below.
- code: |
    def greet(name):
        return f"Hello, {name}!"

    greet("Alice")
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

```{verify}
:id: greet-works
:label: greet is defined and returns a greeting
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
greet("Alice") == "Hello, Alice!"
```
