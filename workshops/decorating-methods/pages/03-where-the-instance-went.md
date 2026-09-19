---
title: Where the instance went
requires: [verify:audit-logs]
---

# Where the instance went

With a working function decorator, the instance is not hidden at all. It
is simply the first positional argument, because that is what `self`
always was.

```{cell-insert}
:id: insert-seen
:path: {{ notebook }}
:tags: [seen]
:run: true
def show_instance(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        wrapper.seen = args
        return func(*args, **kwargs)
    return wrapper

class Probe:
    def __init__(self, name):
        self.name = name

    @show_instance
    def method(self, x):
        return x * 2

probe = Probe("p")
probe.method(5)

print("arguments the wrapper saw:", Probe.method.seen)
print("first one is the instance:", Probe.method.seen[0] is probe)
```

`(<Probe object>, 5)`. The wrapper was called with the instance already
in place, because by the time the wrapper runs, binding has happened:
`probe.method` produced a bound method, and calling it inserted `probe`
as the first argument.

So a decorator that wants the instance can just take it. Name the first
parameter and use it.

```{cell-insert}
:id: insert-audit
:path: {{ notebook }}
:tags: [audit]
:run: true
log = []

def audit(func):
    @functools.wraps(func)
    def wrapper(self, *args, **kwargs):
        log.append(f"{self.name}: {func.__name__}")
        return func(self, *args, **kwargs)
    return wrapper

class Audited:
    def __init__(self, name):
        self.name = name

    @audit
    def sell(self, item):
        return f"sold {item}"

    @audit
    def refund(self, item):
        return f"refunded {item}"

store = Audited("Corner Store")
store.sell("hat")
store.refund("coat")

print(log)
```

The decorator now reads `self.name` off the object it was called on,
which is how a real audit or permission decorator knows who did what.

There is a price, and it is worth being deliberate about. Writing
`def wrapper(self, *args, **kwargs)` means this decorator only works on
methods: put it on a plain function and the function's first argument
gets called `self` and treated as an instance. A decorator meant for
both keeps `*args` and reaches for `args[0]` only when it has reason to
believe there is an instance there, which is guesswork, and is one of
the things `wrapt` exists to solve properly.

```{verify}
:id: audit-logs
:label: The decorator read the instance it was called on
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed audit
log == ["Corner Store: sell", "Corner Store: refund"] and Probe.method.seen[0] is probe
```
