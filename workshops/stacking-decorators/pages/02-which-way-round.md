---
title: Which way round
requires: [quiz:predict-tags, verify:both-orders]
---

# Which way round

Here is the question, before you run anything:

```python
@bold
@italic
def greeting():
    return "hi"
```

Commit to an answer. Being wrong here is more useful than being right,
because whatever model produced the wrong answer is the one worth
correcting.

```{quiz}
:id: predict-tags
:title: Predict the output
:shuffle: true
question: "What does `greeting()` return?"
options:
  - text: "<b><i>hi</i></b>"
    correct: true
  - text: "<i><b>hi</b></i>"
    explanation: "That is what the other order gives. The decorator nearest the function is applied first, so italic goes on first and ends up innermost."
  - text: "<b>hi</b><i>hi</i>"
    explanation: "They are not applied side by side. Each one wraps whatever is below it, so the result nests."
  - text: "<i>hi</i>, because the last decorator wins."
    explanation: "Neither wins. Both run, one inside the other, and both tags appear in the result."
explanation: "italic is nearest the function so it is applied first and sits innermost. bold is applied to the result, so its tags end up outside."
```

Now run it, both ways round.

```{cell-insert}
:id: insert-both
:path: {{ notebook }}
:tags: [both]
:run: true
@bold
@italic
def greeting():
    return "hi"

@italic
@bold
def greeting_reversed():
    return "hi"

print("bold over italic:", greeting())
print("italic over bold:", greeting_reversed())
```

`<b><i>hi</i></b>` and `<i><b>hi</b></i>`. The decorator closest to the
`def` is applied first and finishes up innermost; the one furthest away
is applied last and ends up outermost.

Written out longhand, the stack is nothing more than nested calls:

```python
greeting = bold(italic(greeting))
```

Read from the inside out, that is exactly the order the `@` lines are in
when read from the bottom up. There is no special rule to remember, only
the one rule you already have: `@name` means `f = name(f)`, applied in
turn.

```{verify}
:id: both-orders
:label: Both stacks produce the nesting their order implies
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed both
greeting() == "<b><i>hi</i></b>" and greeting_reversed() == "<i><b>hi</b></i>"
```
