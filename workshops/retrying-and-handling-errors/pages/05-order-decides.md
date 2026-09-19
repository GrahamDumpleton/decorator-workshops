---
title: The order decides what you see
requires: [verify:order-matters]
---

# The order decides what you see

Workshop six said the stacking order sometimes changes the answer rather
than the output. Here is that, with two decorators you have just
written and a difference you would notice at three in the morning.

Both stacks log and both retry. Only the order differs.

```{cell-insert}
:id: insert-order
:path: {{ notebook }}
:tags: [order]
:run: true
records.clear()
tries.clear()

@log_exceptions
@retry(attempts=3)
def log_above():
    raise ConnectionError("down")

try:
    log_above()
except ConnectionError:
    pass

above = len(records)

records.clear()
tries.clear()

@retry(attempts=3)
@log_exceptions
def log_below():
    raise ConnectionError("down")

try:
    log_below()
except ConnectionError:
    pass

below = len(records)

print("logging above retrying -> log lines:", above)
print("logging below retrying -> log lines:", below)
```

One line against three, from the same two decorators.

With **logging above**, the retrying happens underneath it. The logger
only ever sees what escapes the retry loop, so a call that failed twice
and then succeeded is logged not at all, and a call that exhausted its
attempts is logged once. The log is a record of operations that
genuinely failed.

With **logging below**, the logger is inside the loop, wrapping the
function itself, so every attempt is logged. Three lines for one failed
call, and lines for attempts that were followed by success.

Neither is wrong, and which you want depends on the question you expect
to ask. "Which operations failed?" wants logging on top, and gets a log
you can count. "Is this service flaky?" wants logging underneath, and
gets the retries that the other arrangement hides, at the cost of a much
noisier log.

The trap is arriving at either by accident. A quiet log that hides
hundreds of retries and a noisy one that triples every incident are both
things people discover during an outage.

```{verify}
:id: order-matters
:label: One arrangement logged once, the other logged every attempt
:substrate: learner-kernel
:path: {{ notebook }}
:trigger: cell-executed order
above == 1 and below == 3
```
