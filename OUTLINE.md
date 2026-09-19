# Python decorator workshops: outline

The design of the collection: how it is organised, what each workshop
covers, its name and format, and the decisions that cut across all of
them. It is a living document. Read it before adding a workshop, and
update it when one is added, changed or dropped: the status table below
records where each workshop stands, and the open questions section
shrinks as they are settled.

## What this collection is

Fourteen workshops that teach Python decorators with the standard
library alone, in the browser, with nothing to install. The learner meets
decorators as a user, writes one, then learns why it works, then works
through the parts that catch people out and the patterns worth knowing.

The scope stops at decorators. `wrapt`, monkey patching, import hooks
and instrumentation are not taught here: they belong to collections of
their own, and the patching and tracing material already lives in the
wrapture workshops.

## Source material

Python's own documentation is the authority on behaviour: the
[glossary entry](https://docs.python.org/3/glossary.html#term-decorator),
the [data model](https://docs.python.org/3/reference/datamodel.html),
the [execution
model](https://docs.python.org/3/reference/executionmodel.html#naming-and-binding)
for scoping and `nonlocal`,
[functools](https://docs.python.org/3/library/functools.html) and
[inspect](https://docs.python.org/3/library/inspect.html).

## Shape of the collection

One ordered collection, in four movements, with no visible break
between them: the collection is numbered straight through and each
Finish dialog offers the next.

**Understanding one** (1 to 3). What a decorator does, writing one, and
why it works. The learner applies decorators before writing them, and
writes one before being told how it remembers anything. Each of the
three ends with the question the next one answers.

**Getting it right** (4 to 8). The things that go wrong: arguments,
lost metadata, stacking order, methods, and decorators that are
classes. This is where a reader who has copied a decorator from a blog
post finds out what it was missing.

**What else you can decorate** (9 and 10). The mechanism underneath
method binding, and the last kind of target. Descriptors explain the
failure workshops 7 and 8 both ran into and that workshop 8 ends on,
and class decoration closes the loop on the `@dataclass` that workshop 1
opened with.

**Patterns worth knowing** (11 to 14). Four decorators worth having
written once: caching, registration, error handling, and async. Each is
a complete, useful thing rather than a demonstration.

Ten to twenty minutes each, 210 minutes in total, so about three and a
half hours.
Each workshop is self-contained and ships whatever code it needs, so it
can be taken on its own, even though the order is the order to take
them in.

## Naming

Directory names are short kebab-case phrases naming the question, not
the mechanism, with no numeric prefix. The collection index carries the
order, and unnumbered names stay stable as workshops are inserted,
split or moved. Titles are sentence case and read as what the learner
will do.

## The workshops

### 1. `what-a-decorator-does`: What a decorator does

The learner never writes a decorator here and never sees a closure.
They use decorators that already exist and watch what changes.

Start with a function that is slow because it recomputes, call it
twice and time it, then add `@functools.cache` above it and time it
again: same code, same call, different behaviour, one line. Then
`@property`, so an attribute access runs a method. Then
`@dataclasses.dataclass`, so a class gets an `__init__` and a
`__repr__` nobody wrote. Three decorators, three things changed,
nothing yet explained.

Then the reveal, in one cell: `@` is not magic and not new syntax for
the function body. `cheap = functools.cache(expensive)` does the same
thing, and the learner runs both forms and compares. A decorator is
something that takes a function and gives back a replacement, and `@`
is where you say so.

End with the map: to write one you need to know what a function is as
a value, how a function can remember, and how to pass arguments
through. That is the next three workshops, named, so the learner knows
where they are going.

- Format: notebook. Checks read timings and the objects themselves from
  the learner's kernel.

- Length: 10 minutes.

- This workshop exists to be the one a learner finishes. It has to be
  short, has to show a decorator earning its keep in the first two
  minutes, and must not introduce a single thing the learner has to
  take on trust and remember.

### 2. `your-first-decorator`: Your first decorator

The first decorator the learner writes, and the second thing they do.

Write `logging_wrapper` by hand and apply it with
`greet = logging_wrapper(greet)`, which is exactly the form the last
workshop revealed. Only then replace it with `@logging_wrapper` and
confirm the behaviour is identical. Build a `@timer` with
`time.perf_counter()`. Build a `@count_calls` that keeps the count on
`wrapper.call_count`, which is the first hint that the wrapper is an
object with a life of its own. Then before, after and around, so the
three insertion points are explicit.

Close with what happens when the wrapped function raises, which every
wrapper written so far gets wrong: the work after the call is skipped,
so the timer reports nothing for the call most worth timing and the
"after" line never appears. Fix it with `try`/`finally`, then separate
the three cases with `except`, `else` and `finally`, so a wrapper can
tell succeeded from failed from finished. This is the one correctness
point the collection cannot defer: a learner who leaves with the naive
shape writes decorators that lie on the error path.

The wrapper uses `func` after the decorator has returned, and the page
says so plainly and does not explain it: that is the next workshop's
question.

- Format: notebook.

- Length: 20 minutes.

### 3. `how-a-decorator-remembers`: How a decorator remembers

Not a warm-up on first-class functions: the answer to the question
workshop 2 ended on.

Start from the decorator they just wrote: `logging_wrapper` has
returned, its local `func` should be gone, and the wrapper still calls
it. Inspect `wrapper.__closure__` and find `func` in it. Then the
general case with `make_multiplier(n)`, now motivated rather than a toy.
Then `nonlocal` and a counter that the wrapper can increment, which is
the state `@count_calls` was keeping. Finish with late binding in a
loop, the classic pitfall, diagnosed and fixed.

No dispatch table and no `apply_to_list` exercise: the learner has
already passed functions around by hand in workshop 2, so the ground is
covered.

- Format: notebook. Checks read `__closure__`, cell values and the
  fixed loop's output from the learner's kernel.

- Length: 15 minutes.

### 4. `decorators-that-take-arguments`: Decorators that take arguments

Arguments in both directions: the ones the decorated function takes,
and the ones the decorator itself takes, with the dual-use question as
the last page.

Start broken: `@timer` applied to a function with a different signature,
and `@timer("ms")` failing outright. Fix the first with `*args` and
`**kwargs` forwarding, and see why the return value has to be passed
back too. Fix the second by adding the outer layer, built one step at
a time so the three nested functions are three separate ideas rather
than a wall. Then `@repeat(n)`, then a `@retry(max_attempts=3,
delay=0.1)` worth keeping.

The last page is the one people hit in practice: a decorator that works
both as `@debug` and as `@debug(prefix=">>>")`, why the two forms
cannot both be the same call, and the callable-detection and sentinel
ways of handling it.

- Format: notebook.

- Length: 15 minutes.

### 5. `preserving-the-wrapped-function`: Preserving the wrapped function

Short, and the first time the learner finds out that everything they
have written so far has been quietly breaking something.

Ask `greet.__name__` after decorating and get `wrapper`. Ask for
`help(greet)` and get the wrapper's signature and no docstring. Then
`@functools.wraps`, and the same questions answered correctly. Look at
what it copies, `WRAPPER_ASSIGNMENTS` and `WRAPPER_UPDATES`, and find
`__wrapped__` pointing back at the original.

Then what `wraps` does and does not buy, which is not what most advice
says. The usual claim is that `inspect.signature()` still reports
`(*args, **kwargs)` and `inspect.getsource()` still shows the wrapper.
Both are false on any Python since 3.4: `inspect` follows
`__wrapped__`, so with `wraps` the signature is the original's and
`getsource` returns the original's source. Checked against 3.14 before
writing, because the claim is repeated wherever the limits of `wraps`
come up.

What is actually left: `inspect.signature(fn, follow_wrapped=False)`
still shows `(*args, **kwargs)`, which is what a tool that does not
follow the link sees; the wrapper really does accept any call, so a
wrong one fails one frame in rather than at the boundary; and a
decorator that forgets `wraps` loses the lot, name, docstring,
signature, source and `__wrapped__` together, which is the contrast the
page ends on.

- Format: notebook.

- Length: 10 minutes.

### 6. `stacking-decorators`: Stacking decorators

The workshop where the mental model has to become precise.

Predict, then run: `@bold` over `@italic` and the other way round.
Make the onion visible with two tracing decorators that print on the
way in and on the way out, so application order (bottom up) and
execution order (top down) are seen as two different things rather
than one confusing one. Then a practical case where the order changes
the answer: a call counter stacked with `@functools.cache` both ways,
which counts every call above the cache and only the uncached ones
below it, so the learner reasons about which number they wanted.

Not `@timer` with `@count_calls`, the obvious pairing: the difference
there is unobservable. Not `@count_calls` with `@repeat` either, which
looks ideal and is a trap: `wraps` copies `__dict__`, so the outer
wrapper holds a stale snapshot of `call_count` and the answer is 0
rather than the expected 3. True, and too much of a detour for this
workshop. Finish by walking a three-deep chain through `__wrapped__`,
including one decorator that breaks the chain by forgetting `wraps`.

- Format: notebook. The prediction steps close with a quiz before the
  cell is run, so the learner commits to an answer first.

- Length: 15 minutes.

### 7. `decorating-methods`: Decorating methods

The most common real-world surprise, and the one people search for.

Apply a working function decorator to an instance method and watch it
work. Then apply a class-based one and watch it fail, not with the
"missing self" the usual advice promises but with
`TypeError: Shop.breaks() missing 1 required positional argument:
'item'`: the instance was never passed, so every argument shifted along
by one, and the last one fell off the end. Find the instance sitting in
`args[0]` and write a decorator that uses it.

Then ordering with `@staticmethod` and `@classmethod`. The widely
repeated rule, that a custom decorator goes above them, is the wrong way
round on any Python since 3.10, and was checked against 3.14 before
writing. What actually happens:

- `@custom` over `@classmethod` fails always, on the class and on an
  instance alike, with `TypeError: 'classmethod' object is not
  callable`.

- `@custom` over `@staticmethod` is worse, because it half works: fine
  called on the class, `TypeError: takes 1 positional argument but 2
  were given` called on an instance.

- `@staticmethod` or `@classmethod` on top, with the custom decorator
  underneath, works both ways. That is the rule.

Close with broken examples to diagnose and fix.

The mechanism behind the breakage, the descriptor protocol, is named
here and taught in workshop 9, which the hint on that page points
forward to by name.

- Format: notebook.

- Length: 15 minutes.

### 8. `class-based-decorators`: Decorators that are classes

Placed after methods rather than before, so the learner already knows
the failure mode a class brings with it.

Any callable can be a decorator. Convert `@count_calls` to a class with
`__init__` and `__call__`, and find that the count now lives in an
instance attribute rather than a closure cell, which is the real reason
to reach for a class. Discover the metadata problem again and fix it
with `functools.update_wrapper(self, func)`. Build a
`@RateLimit(calls=5, period=60)`, where the factory layer is just the
constructor. Finish by writing one decorator both ways and comparing
them on readability, state and testability.

- Format: notebook.

- Length: 15 minutes.

### 9. `how-methods-bind`: How methods bind

Placed here because workshop 8 ends on an unresolved failure whose
answer is exactly this, and because it finishes the mechanism before the
collection turns to applications.

Bind a method by hand: `Service.call` is a function, `service.call` is a
`method`, and `Service.call.__get__(service, Service)` produces the
second from the first. Then pick up the class-based decorator that
failed in workshop 8 and show why. `Svc.call is svc.call` is `True`,
because a `Counted` instance has no `__get__`, so the lookup has nothing
to call and hands the instance straight back. The instance was never
involved, which is also why the error names `self` rather than a later
argument: nothing shifted along.

Fix the binding with `__get__` returning `types.MethodType(self,
instance)`, then find the count still shared, three calls across two
objects reporting `3`. That is the distinction workshop 8 stated too
simply and this workshop exists to draw: `__get__` fixes binding, and
what `__get__` *returns* fixes state. Fix it with `__set_name__` and a
per-instance `BoundCounter` cached in `instance.__dict__`, which works
because a class defining only `__get__` is a non-data descriptor, so the
instance dictionary wins on later lookups.

Close with a descriptor that has nothing to do with decorators, a
validated `Positive` attribute, so the protocol reads as a language
feature rather than a decorator trick.

Verified against 3.14 before writing: the shared count is `3`, the
per-object counts are `2` and `1`, and looking the attribute up on the
class and on an instance returns the same object.

Verified afterwards, and carried on page 5 as a hint: the instance
dictionary cache works only while the descriptor is the class
attribute, so it has to be the outermost decorator. A function
decorator above it raises `TypeError: 'CountedPerObject' object is not
callable`, because `__set_name__` fires only for objects assigned
directly in a class body and never for a wrapped one. An outer
decorator that is itself a descriptor and forwards `__set_name__` is
worse: measured over three calls it ran once, then the cached counter
shadowed it and it silently stopped taking part, with every call still
returning the right answer. `functools.cached_property` has the same
restriction, which is the honest framing: this is the idiom's trade-off
rather than a defect in the example.

- Format: notebook.

- Length: 20 minutes.

### 10. `decorating-classes`: Decorating classes

Placed last in the mechanism group because it is half application
already, so it bridges to the patterns that follow. No registry example
here, which would pre-empt workshop 12.

Show that the decorator receives the class object itself and usually
hands it straight back, `show_target(Widget) is Widget`. Then three
things a class decorator can do. Synthesise a `__repr__` from
`vars(self)`. Add `__eq__` and `__lt__` from named fields, and meet the
trap: assigning `__eq__` after the class exists does not reset
`__hash__`, so two equal objects keep distinct identity-based hashes and
a set holds both, where defining `__eq__` in a class body sets
`__hash__` to `None` and turns the same mistake into a `TypeError`.
Then `@frozen`, which has to wrap `__init__` as well as replace
`__setattr__`, and needs `object.__setattr__` to avoid re-entering
itself.

Finish on `@dataclass`, applied with `@` and by hand as
`Manual = dataclasses.dataclass(Manual)`, which is workshop 1's rule
with a class in place of a function. It also makes the decision the page
before skipped: having added `__eq__`, it sets `__hash__` to `None`.

Verified against 3.14 before writing: `Pair.__hash__ is None` is
`False`, the two equal objects hash differently, a set of both has two
entries, and `InBody.__hash__ is None` is `True`.

- Format: notebook.

- Length: 15 minutes.

### 11. `caching-results`: Caching results

The first of the four patterns, and the one the collection already
showed off in workshop 1.

Write a naive dict-based `@memoize` and put it on recursive Fibonacci,
counting how often the body runs so the effect is visible: 21 runs for
`fib(20)` rather than tens of thousands. Then break it in two different
ways. A keyword call does not quietly miss the cache, as is often
assumed; a wrapper keyed on `*args` alone rejects it outright with
`TypeError: area() got an unexpected keyword argument 'width'`, which
is a sharper lesson. Passing a list raises
`TypeError: cannot use 'tuple' as a dict key (unhashable type:
'list')`. Normalise with `inspect.signature` and `bind`, after which
`box(3)`, `box(width=3)` and `box(3, 2)` all reach one entry. Then the real thing,
`functools.lru_cache` with `maxsize` and `cache_info()`, and
`functools.cache` with a demonstration of why unbounded caching is a
memory leak with good manners. Finish by adding TTL expiry with
`time.monotonic()`.

- Format: notebook.

- Length: 15 minutes.

### 12. `registering-functions`: Registering functions

Included because it is the decorator shape people meet first in real
code, in Flask, Click and pytest, and because it is the one that breaks
the pattern.

The decorator here does not wrap anything: it records the function and
returns it unchanged. Build a name-keyed registry, then a command
dispatcher with `register` and `dispatch`, then a minimal
`@app.route("/path")` with a `handle_request` that looks the handler
up. Then an event system where `@on("user_created")` allows several
handlers for one event, and `emit()` calls them all.

Seeing a decorator that changes nothing about the function is worth a
workshop on its own: it separates "decorator" from "wrapper" in the
learner's head.

- Format: notebook.

- Length: 15 minutes.

### 13. `retrying-and-handling-errors`: Retrying and handling errors

The four things a wrapper can do about an exception: log it, translate
it, retry it, or suppress it.

A `@log_exceptions` that logs through the `logging` module and
re-raises, so nothing is swallowed. A `@transform_exceptions` that
re-raises as a different type with `raise ... from ...`, and a look at
`__cause__` to see the original is still there. A `@retry` with
exponential backoff and jitter, and `retry_on` to choose which
exceptions are worth another attempt. A `@suppress` with a frank page
on when it is the wrong answer.

The closing page stacks `@log_exceptions` with `@retry` both ways, so
the learner sees the order decide whether every attempt or only the
final failure is logged, which is the practical payoff of workshop 6.

This workshop is about reacting to an exception: catching it, logging
it, retrying, translating it. The separate question of a wrapper whose
own work is skipped when the call raises belongs earlier, and is
settled in workshop 2 with `try`/`finally`, which this one assumes.

- Format: notebook. Sleeps are kept to tens of milliseconds: the
  browser feels them.

- Length: 15 minutes.

### 14. `decorating-async-functions`: Decorating async functions

The last of the patterns, and the one where an ordinary decorator fails
without saying so.

Start with the silent failure: put a normal `@timer` on an `async def`
and watch it report almost no time, because it timed how long it took
to create a coroutine object rather than to run it. Write an
`@async_timer` whose wrapper is itself `async def` and awaits the
result. Then a `@universal_timer` that checks
`inspect.iscoroutinefunction()` at decoration time and returns whichever
wrapper fits, so one decorator serves both. Then `@async_retry` with
`asyncio.sleep()`. Finish with the blocking pitfall: synchronous work
inside an async wrapper stops everything.

The blocking demonstration spins on `time.perf_counter()` rather than
calling `time.sleep()`, because Pyodide's `time.sleep()` returns to the
browser's event loop while it waits, so sleeping coroutines interleave
there and the page would teach something false where it is read. The
page says so, and keeps the CPython warning about a `time.sleep`
backoff, which is the case that costs a server its concurrency.

Not `asyncio.iscoroutinefunction`, which older advice uses. It
emits a `DeprecationWarning` on 3.14 and is slated for removal in 3.16,
with the runtime itself pointing at `inspect.iscoroutinefunction`
instead. The third outdated API the collection has to correct, after the
`wraps` claims in workshop 5 and the `staticmethod` ordering rule in
workshop 7, which is why every example here is run before it is
believed.

The sync timer applied to an `async def` also leaves an un-awaited
coroutine behind, which Python reports as a `RuntimeWarning` and which
would clutter the notebook. The page closes it explicitly, which is
worth showing anyway: it is what you do with a coroutine you decided not
to run.

Notebook cells allow top level `await`, so the learner writes
`await slow()` directly. `asyncio.run()` is never used: it cannot block
the browser's event loop the way it does in CPython.

- Format: notebook, with top level `await` throughout.

- Length: 15 minutes.

## Topics not covered

Several topics were considered and left out, and the reasons are worth
recording so the decisions can be revisited rather than rediscovered.
Signature preservation in depth is deep ground and was largely there to
motivate `wrapt`, which is not taught here. Validation, access control,
deprecation and profiling are four more turns of the same wrapper shape
that workshops 11 to 14 already establish. Context managers are good and
simply did not make the cut. Metaclasses are a step beyond the audience.
Thread safety cannot be taught in the browser at all, because Pyodide
cannot start a thread.

## Decisions that cut across the workshops

**JupyterLite is the primary target.** Every workshop must run in the
browser with no server, which is what makes the collection openable from
a link with nothing installed. This is the constraint that decides the
format, and the full set of rules it implies is in AGENTS.md. In short:
notebook driven, kernel checked, no terminal, no environment, no
subprocess, no threads, and `await` rather than `asyncio.run`.

**One format.** Every workshop is a notebook. There is no terminal
workshop here and no mixed workshop, because the subject never needs
one: decorators are things you do to Python objects, and a notebook is
where Python objects live. It falls out of the subject rather than
being imposed on it.

**Standard library only.** Nothing is installed, by the workshops or for
them. No `environment` key, no `requirements.txt`, no
`install-packages` capability. The ambient Pyodide kernel is the whole
environment. This is what keeps the collection openable in the browser,
and it is also why the scope stops where it does.

**Learners never type code.** Every cell arrives through a
`cell-insert` action, so the learner's attention goes on reading and
predicting, not on typing and typos.

**Checks.** Every page ends with something checkable. The substrate is
`learner-kernel` for what the learner's notebook holds, triggered by
`cell-executed <tag>`, and `contents` where a file or a run is the
question. Checks say what is wrong rather than that something is: "the
wrapper has no `__wrapped__`, so `functools.wraps` was not applied"
rather than "check failed". A `hint` beside a check says what to look
at when it fails.

**Prediction before execution.** Where a result is surprising, and in
this subject it often is, the page asks for a prediction in a `quiz`
before the cell runs. Stacking order, the method `TypeError` and the
async timer that reports no time are all better learned by being wrong
first. The self-test answers quizzes correctly, so this costs nothing
in CI.

**Examples.** There is no single running example across the collection,
because each pattern has a natural one and forcing a shared cast would
cost more than it saves. A small recurring pair, a `greet` and a slow
`fetch_price`, is reused where it fits, so the early workshops at least
feel continuous.

**Timing and sleeps.** Every sleep is tens of milliseconds. Pyodide's
`time.sleep()` works, but it is felt by the page, and a workshop that
pauses a browser for a second per cell reads as broken.

**Platforms and frontends.** Every manifest declares
`platforms: [linux, macos, windows]` and
`frontends: [jupyterlab, jupyterlite]`. There are no commands in any
workshop, so there is nothing platform specific to get wrong, and
Windows costs nothing here.

**Self-test on both frontends.** A workshop is done when
`just test <name>` and `just test-lite <name>` are both green. The Lite
self-test runs it in a real browser on the Pyodide kernel, which is
what learners get, so it is the one that counts.

**Ordered collection.** `jupyter workshop index` is run with
`--ordered`, which numbers the workshops in the browser and makes each
Finish dialog offer the next; the Justfile passes it.

**Published home.** The collection lives at
`https://github.com/GrahamDumpleton/decorator-workshops`. That is the
Justfile's `collection_repo`, which `just index` passes to `--repo`, so
every entry in `collection.json` carries it.

**Binder and Codespaces are both offered.** Either runs the collection
on a real CPython from a link in the README, which is what a reader who
wants the workshops rather than the repository is given. `binder/` holds
the image: the locked runtime requirements, the Python version, a
`postBuild` that writes JupyterLab's settings, and the welcome message.
`.devcontainer/` holds the codespace, installing the same requirements
with pip and starting JupyterLab on port 8888. Both subscribe to
`collection.json`, so the workshops are listed in the collection's
order, and both disable opening other directories, subscribing to other
collections and author mode, which keeps a visitor to the workshops the
link was for.

They differ on trust, and on purpose. A Binder session is an anonymous
container thrown away at the end, so the workshops are forced to
trusted and no dialog interrupts a visitor who chose the link. A
codespace belongs to the reader's GitHub account and persists, so it
trusts nothing for them and JupyterLab starts without the codespace's
GitHub token.

Both report anonymous progress events to the workshops' own analytics
service, which is how it can be seen where a workshop loses people.
Each carries an ingest token of its own, labelled `decorator-binder`
and `decorator-codespaces`, so the service tells the two apart and
either can be revoked alone; the tokens are public by construction,
since the settings scripts are. Each welcome message tells the visitor
that progress is reported and what is never sent. The JupyterLite site
reports nothing yet.

Neither is needed by the workshops themselves, which want no terminal
and install nothing. They are there because a real CPython is the
honest place to check anything the browser's Python does differently,
which the async workshop turned out to need.

**CI and the published site.** `.github/workflows/test.yml` lints and
self-tests every workshop on both frontends on each push, spelling the
commands out rather than running the Justfile so the job needs nothing
but uv. It runs on Linux alone: no workshop here runs a command, so
there is nothing platform specific to get wrong, and the JupyterLite
runs need no node, npm or micromamba because the self-test leaves the
terminal out for a workshop that declares no terminal capability.

`.github/workflows/pages.yml` publishes the JupyterLite site to GitHub
Pages, triggered by that workflow finishing successfully on `main`, so
nothing reaches the site that has not been tested. It checks out the
commit the tests ran on rather than whatever `main` points at by then.
The site is built with `--trust trusted`, on the same reasoning as
Binder: a Lite site runs entirely in the visitor's browser, so nothing
a workshop does reaches their machine.

That also settles the teaching order, which used not to reach the built
site. The build now passes `--collection`, naming the copy of
`collection.json` published beside the site, and
`actions/configure-pages` supplies the base URL so it is not written
out by hand. The site's `jupyter-lite.json` carries that URL in its
`collections` setting, so the workshop browser lists the fourteen
numbered in the collection's order rather than alphabetically. If the
index ever fails to fetch, the site still works and falls back to
listing them in directory order.

## Extension features the workshops use

The patterns settled from the extension's documentation in
`reference/jupyterlab-workshop/docs`, so each workshop does not
rediscover them. The authoring skill covers the syntax; this records the
choices.

**Notebook pages.** The welcome page creates the notebook with
`notebook-create`; each later step is one `cell-insert` with a tag and
`:run: true`, so a page reads as prose, cell, check. The check is a
`learner-kernel` verify, an expression evaluated in the learner's own
kernel, triggered by `cell-executed <tag>`, asking the question
directly: does the wrapper have the original's name, how many times was
it called, what did the stacked pair return. Pages gate on those
verifies with `requires`.

**One idea per cell.** A cell shows only its last expression, so a cell
that changes state and then makes a call shows the call and never the
change. Multi-line strings and anything whose shape matters are shown
with `print()`.

**Shipped files.** Where a workshop needs code the learner should not
have to read being typed in, it ships under `files/`, which the
extension copies into the workspace on first open. Most workshops need
none: the code is the point, so it goes in cells.

**Layout.** Each workshop declares a layout of one named placeholder
area, which opens nothing and holds the notebook once the welcome page
creates it. Never the built-in `default` or `terminal-only`: both open
a terminal named `workshop`, which these workshops have no capability
for and a JupyterLite site built without the terminal cannot provide.
Nothing warns about that, so it has to be remembered.

The main area is therefore empty until the learner clicks the first
action, and the welcome page says so. Making the notebook appear at
open is not worth what it costs: auto-running `notebook-create`
destroys the learner's work on any return to the welcome page, and
shipping the notebook in `files/` means hardcoding a `kernelspec` whose
name differs between JupyterLab and JupyterLite.

**Manifest.** `resumable` is left unset, so false. The files survive a
browser reload but the kernel does not, and these workshops do carry
names across pages in that kernel: ten of the fourteen have a final page
whose cells raise `NameError` when run against a fresh one. Marking
them resumable would drop the learner back in silently and break on
their next click, where leaving it unset asks whether to Restart or
Continue. Restart is the default and the consistent choice, and costs
little when every cell arrives by clicking rather than being typed.
Continue is recoverable too, because every notebook here replays top to
bottom, so "Restart Kernel and Run All Cells" rebuilds the session.
`gating` is `soft`. `duration` and `tags` are filled in, and `finish` names the next
workshop in the sequence. No `env`, no `requires.tools`, no
`environment`.

**No tracks.** The extension supports a track chosen by the learner. The
workshops here never use it: a variant that wants different pages is a
separate workshop, which keeps each one small and lets the self-test
cover every page.

## Status

The writing order was the collection order. Workshop 1 was to be
revisited last, once the workshops it promises existed, so that it could
name them accurately; that turned out to need no change, since the three
it names are the three that follow it and their titles did not move.

Each workshop's Python was run against a real 3.14 interpreter before
any of it was written into a cell. That caught four widely repeated
claims that are wrong or have since changed, recorded in the entries for
workshops 5, 6, 7 and 14, and it is the practice to keep. Workshops 9
and 10 were verified the same way before a line was written, which is
where the shared count in 9 and the surviving `__hash__` in 10 came
from.

Each workshop is scaffolded, written, linted clean on both frontends,
self-tested on both frontends, indexed, added to the README and
committed before the next starts. Status is one of: planned, in
progress, written (lint clean), tested (both self-tests green),
published (indexed and in the README, not yet in git), or committed
(published and in git, with the commit that added it).

| # | Workshop | Status |
|---|----------|--------|
| 1 | `what-a-decorator-does` | published, 14 pass |
| 2 | `your-first-decorator` | published, 22 pass |
| 3 | `how-a-decorator-remembers` | published, 17 pass |
| 4 | `decorators-that-take-arguments` | published, 16 pass |
| 5 | `preserving-the-wrapped-function` | published, 12 pass |
| 6 | `stacking-decorators` | published, 13 pass |
| 7 | `decorating-methods` | published, 11 pass |
| 8 | `class-based-decorators` | published, 13 pass |
| 9 | `how-methods-bind` | published, 15 pass |
| 10 | `decorating-classes` | published, 16 pass |
| 11 | `caching-results` | published, 16 pass |
| 12 | `registering-functions` | published, 11 pass |
| 13 | `retrying-and-handling-errors` | published, 13 pass |
| 14 | `decorating-async-functions` | published, 15 pass |

All fourteen are lint clean on both frontends and green under the
JupyterLab self-test, 204 checks and actions in total with no failures,
and the JupyterLite site builds carrying all of them. All fourteen have
now been run under the JupyterLite self-test as well, on the Pyodide
kernel in a real browser, which is the check that counts, and all
fourteen are green. There are no known blockers.

The one failure the Lite runs turned up was in
`decorating-async-functions`, whose page 5 taught that `time.sleep`
inside a coroutine cannot interleave. It cannot on CPython, which is
why the JupyterLab self-test passed it, but Pyodide's `time.sleep`
returns to the event loop, so both halves of the contrast interleaved
in the browser. The demonstration now spins on `time.perf_counter()`,
which holds the loop on both frontends, and the page names the
difference.

The authoring trap the first three workshops turned up, a verify with
several `cell-executed` triggers failing with a `NameError` on names the
later cells define, was a defect in the extension: a check that raised
in the notebook's kernel made the kernel drop the cell queued behind it.
It is fixed in jupyterlab-workshop 0.7.0, which is the pinned release,
so the one trigger per verify rule that worked around it is gone from
AGENTS.md.

## Open questions

Decisions not yet taken. Remove each as it is settled and record the
answer in the section it belongs to.

- **Analytics from the published site.** Binder and Codespaces report
  progress events; the JupyterLite site does not. `jupyter workshop
  lite` writes the settings it is given and has no analytics option, so
  a sink there means writing the site's overrides another way. Since the
  site is the link most people will follow, it is also where the numbers
  would say the most, which is the case for doing it rather than leaving
  it.

