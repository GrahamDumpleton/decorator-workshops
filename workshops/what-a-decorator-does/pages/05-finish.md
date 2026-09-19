---
title: What you know now
requires: [quiz:what-at-means]
---

# What you know now

You used three decorators and never wrote one:

- `@functools.cache` made a slow function skip work it had already
  done, and added a `cache_info` method that the original never had.

- `@property` made a method read like an attribute, and made it refuse
  to be assigned to.

- `@dataclasses.dataclass` was applied to a class, not a function, and
  gave it an `__init__`, a `__repr__` and an `__eq__` nobody wrote.

And you know what the `@` line means, which is the part that makes the
rest make sense.

```{quiz}
:id: what-at-means
:title: What the @ line does
:shuffle: true
question: "What does `@shout` above `def greet(name)` do?"
options:
  - text: "Defines greet, passes it to shout, and binds the name greet to whatever shout returns."
    correct: true
  - text: "Runs shout every time greet is called, then runs greet."
    explanation: "Close, and it is often the effect, but the decorator itself runs once, at definition time. What runs on every call is whatever shout gave back."
  - text: "Marks greet so Python calls it differently from then on."
    explanation: "Nothing about greet is marked. After the decorator runs, the name greet points at a different object, and Python calls that object in the ordinary way."
  - text: "Copies the body of shout into greet."
    explanation: "No code is copied or rewritten. The original function is untouched; something else is put in front of it."
explanation: "@shout above a def is shorthand for greet = shout(greet). That one rule explains everything else a decorator does."
```

## Where this goes next

To write your own decorator you need three things, and each is the next
workshop along:

- **Your first decorator** shows you the shape: a function that takes a
  function and returns a replacement. You write it by hand first, then
  with `@`.

- **How a decorator remembers** answers the question the first one will
  leave you with: how the replacement still knows about the original
  after the decorator has finished and returned.

- **Decorators that take arguments** covers `@repeat(3)`, where the
  decorator needs configuring, and why that takes one more layer than
  you would expect.

Press Finish below to move on.
