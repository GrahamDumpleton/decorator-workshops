---
title: Many handlers for one event
requires: [verify:events-fire]
---

# Many handlers for one event

A registry that maps a name to one function is a dispatcher. Map a name
to a *list* of functions and it becomes an event system, where several
unrelated pieces of code can each ask to hear about the same thing.

The only change is `setdefault` and `append` in place of an assignment.

```{cell-insert}
:id: insert-events
:path: {{ notebook }}
:tags: [events]
:run: true
handlers = {}

def on(event):
    def decorator(func):
        handlers.setdefault(event, []).append(func)
        return func
    return decorator

fired = []

@on("user_created")
def send_welcome_email(user):
    fired.append(f"email to {user}")

@on("user_created")
def add_to_crm(user):
    fired.append(f"crm record for {user}")

@on("user_deleted")
def purge_data(user):
    fired.append(f"purged {user}")

def emit(event, *args):
    for handler in handlers.get(event, []):
        handler(*args)

emit("user_created", "ada")
emit("user_deleted", "bob")
emit("nothing_listens_to_this", "x")

print(fired)
```

Two handlers ran for `user_created`, in the order they were registered,
and emitting an event nobody listens for did nothing rather than
failing.

This is the pattern's real argument. `send_welcome_email` and
`add_to_crm` know nothing about each other, and whatever creates a user
knows about neither. Adding a third thing that should happen when a user
is created means writing one function with one decorator, and changing
nothing anywhere else. Removing it means deleting that function.

The cost is the other side of the same coin: nothing at the point a user
is created tells you what will happen next. You have to know to go
looking for the handlers, and they can be in any file that has been
imported, which is the other thing to know: a handler that is never
imported is never registered, so plugin systems built this way spend
their effort on making sure the right modules get loaded.

```{verify}
:id: events-fire
:label: Both handlers ran, in order, and an unknown event did nothing
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed events
fired == ["email to ada", "crm record for ada", "purged bob"] and len(handlers["user_created"]) == 2
```
