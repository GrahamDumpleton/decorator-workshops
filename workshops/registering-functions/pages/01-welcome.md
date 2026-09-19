---
title: Welcome
requires: [verify:setup-ready]
---

# Registering functions

Every decorator so far has replaced a function with a wrapper. This one
does not replace anything. It takes your function, writes its name down
somewhere, and hands the very same object back.

Which sounds like a decorator that does nothing, and in a sense it is:
the function is untouched and calling it behaves exactly as before. What
changed is that something else now knows the function exists.

That is the decorator you have most likely already used. Flask's
`@app.route`, Click's `@click.command`, pytest's `@pytest.fixture` are
all this: a way of saying "here is a thing, remember it" at the point
the thing is defined, rather than in a list somewhere else that someone
will forget to update.

```{notebook-create}
:id: create-notebook
:path: {{ notebook }}
:open: true
- markdown: |
    # Registering functions
    Each step of the workshop adds a cell below.
- code: |
    commands = {}

    def command(name):
        def decorator(func):
            commands[name] = func
            return func
        return decorator

    commands
  tags: [setup]
```

```{cell-run}
:id: run-setup
:path: {{ notebook }}
:cell: setup
```

Read `decorator` before you go on, because the whole workshop is in
those two lines. It stores the function in a dictionary, then returns
`func` itself. Not a wrapper. Not a new object. The function it was
given.

```{verify}
:id: setup-ready
:label: The registry and the decorator are defined
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: after:run-setup; cell-executed setup
commands == {} and callable(command)
```
