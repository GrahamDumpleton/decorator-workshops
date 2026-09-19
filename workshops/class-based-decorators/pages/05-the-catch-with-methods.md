---
title: The catch with methods
requires: [verify:still-breaks]
---

# The catch with methods

`Counted` now keeps its identity and counts correctly. Put it on a
method and it still fails, exactly as it did in the last workshop, and
`update_wrapper` does not help at all.

```{cell-insert}
:id: insert-method
:path: {{ notebook }}
:tags: [method]
:run: true
class Service:
    def __init__(self, name):
        self.name = name

    @Counted
    def call(self):
        return "ok"

service = Service("one")

try:
    service.call()
    problem = "no error"
except TypeError as error:
    problem = str(error)

print("Service.call is a:", type(Service.call).__name__)
print("problem:", problem)
```

The same `TypeError`, naming the argument that fell off the end.
`update_wrapper` copied names and docstrings, which is about what the
object *says*. Binding is about what the object *does* on lookup, and
nothing has been done about that.

There is a second problem here that the error hides. A decorator applied
in a class body runs once, when the class is defined, so there is one
`Counted` instance for the whole class rather than one per object. Even
if binding worked, every `Service` would share a single count. State on
the decorator is per decorated function, never per instance, which is
usually not what someone counting calls on an object wants.

Both problems hook into the same method. Give the class a `__get__` and
it becomes a descriptor, which is what functions use to bind themselves:
`__get__` receives the instance and can hand back something that knows
about it. That fixes the binding outright. The shared count takes one
step more, because it depends on *what* `__get__` hands back.

That is the descriptor protocol, and it is the subject of the next
workshop, **How methods bind**, where you fix both of these.

The practical advice meanwhile is short. Use a class-based decorator on
plain functions, where it is a good fit. For methods, use a
function-based decorator, which binds correctly because what it returns
is a function.

```{verify}
:id: still-breaks
:label: The class-based decorator still cannot bind to an instance
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed method
type(Service.call).__name__ == "Counted" and "missing 1 required positional argument" in problem
```
