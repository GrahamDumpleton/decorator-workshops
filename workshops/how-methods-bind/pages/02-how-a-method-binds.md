---
title: How a method binds
requires: [verify:binding-by-hand]
---

# How a method binds

Start with what is actually there. `call` was written once, in the class
body, as a plain function. Ask for it two ways and you get two different
kinds of object.

```{cell-insert}
:id: insert-binding
:path: {{ notebook }}
:tags: [binding]
:run: true
plain = Service.call
bound = service.call

kinds = (type(plain).__name__, type(bound).__name__)

print("Service.call is a:", kinds[0])
print("service.call is a:", kinds[1])
print("bound.__self__ is service   :", bound.__self__ is service)
print("bound.__func__ is Service.call:", bound.__func__ is plain)
```

Looked up on the class, it is the function you wrote. Looked up on an
instance, it is a `method`: a small object holding the function and the
instance together. `__self__` is the instance it remembers and
`__func__` is the original function, unchanged.

So the instance is not passed at the call site. It is attached at
*lookup*, before any call happens. `service.call` has already done the
work by the time the `()` arrives.

What did that? The function itself. Functions have a `__get__` method,
which is what makes them descriptors, and Python calls it whenever a
function is looked up on an instance. You can do the same thing by hand.

```{cell-insert}
:id: insert-by-hand
:path: {{ notebook }}
:tags: [by-hand]
:run: true
by_hand = Service.call.__get__(service, Service)

print("by hand:", type(by_hand).__name__)
print("calling:", by_hand())
print("same answer as service.call():", by_hand() == service.call())
```

That is the whole mechanism. `service.call` is shorthand for
`Service.call.__get__(service, Service)`, and the `method` object is
what `__get__` chose to return.

The rule Python follows is simple: when an attribute found on the class
has a `__get__`, the interpreter calls it and hands you the result
instead of the object itself. Anything with a `__get__` gets to decide
what it becomes when looked up.

```{verify}
:id: binding-by-hand
:label: You produced a bound method by hand
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed by-hand
kinds == ("function", "method") and type(by_hand).__name__ == "method" and by_hand() == "ok from one"
```

```{hint}
:title: Why `__get__` takes two arguments
`__get__(instance, owner)` gets the instance, which is `None` when the
lookup was on the class itself, and the class the attribute was found
on. That `None` is how a descriptor tells `Service.call` apart from
`service.call`, which is why the next pages check for it.
```
