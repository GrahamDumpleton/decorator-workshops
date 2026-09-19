# Agent guidance for decorator-workshops

## Project

This repository is a collection of guided JupyterLab workshops that
teach Python decorators: what a decorator does, how to write one, and
why it works. The workshops run on the jupyterlab-workshop extension:
each is a directory under `workshops/` holding a `workshop.yaml`
manifest and MyST Markdown pages whose fenced directives are clickable
actions. See README.md for how the workshops are run.

The audience is Python developers who have not written a decorator
before, or who have copied one without understanding it. Each workshop
takes one question a reader might have and has them answer it by doing
it, in a live session, with checks confirming each step. Ten to fifteen
minutes each.

The scope is decorators in Python and its standard library. Nothing
here teaches `wrapt`, monkey patching or import hooks: those belong to
separate collections, and the tracing and patching material already
lives in the wrapture workshops.

The scratch/ directory is not part of the git repo. It holds temporary
working files, plans an agent is asked to generate, and the record of
topics held back from this collection. Its contents come and go, so
never reference scratch/ files by name from code or documentation that
will be committed.

## JupyterLite is the primary target

This is the constraint that shapes everything else. The workshops must
run in JupyterLite, which is JupyterLab compiled to run entirely in the
browser: a static site with a Pyodide kernel, no server, no subprocess
and no package installs. That is what lets a learner open a link and
start, with nothing to install and no account.

It follows that every workshop here is notebook driven and kernel
checked, with no terminal at all:

- The manifest declares `platforms: [linux, macos, windows]` and
  `frontends: [jupyterlab, jupyterlite]`. Supporting JupyterLite is an
  explicit declaration; a manifest listing no frontends is JupyterLab
  only.

- Capabilities are `write-files` and `kernel-exec`, and nothing else.
  Never declare `terminal`, and never declare `install-packages`.

- No `environment:` key and no `requirements.txt`. The workshops are
  standard library only, so the ambient kernel is all they need, and
  an isolated environment cannot be built in the browser anyway.
  `environment-create` is the one action JupyterLite cannot run.

- Checks use the `learner-kernel` substrate for what the learner's
  notebook holds, and `contents` for files and `cell-executed`. Never
  use the `script` substrate, which needs the server, and never the
  `shell` substrate or `execute-capture`, which need a terminal.

- No `subprocess`, `os.system`, `multiprocessing` or `socket` in any
  cell or check. Lint flags these for JupyterLite and Pyodide cannot
  run them.

- No threads. `threading` imports in Pyodide but `Thread.start()`
  raises `RuntimeError: can't start new thread`. Locks construct and
  acquire, so code using them runs, but a race cannot be demonstrated.
  Do not write a workshop whose point is contention.

- Async works, through Pyodide's event loop, and notebook cells allow
  top level `await`. Write `await coro()`, never `asyncio.run(...)`,
  which cannot block the browser's loop the way CPython's does.

- `time.sleep()` works and no longer busy waits everywhere, but keep
  sleeps short: they are still felt by the page.

- `time.sleep()` inside a coroutine does not block Pyodide's event
  loop, where CPython's does: it returns to the loop while it waits, so
  sleeping coroutines interleave in the browser and a page teaching
  otherwise is wrong where learners read it. To hold the loop on both
  frontends, spin on `time.perf_counter()` for a few milliseconds
  instead of sleeping.

- Never set `resumable: true`. It looks right, because the files do
  survive a browser reload, but these workshops keep something live
  between pages: the kernel holds every name the earlier pages defined,
  and later pages use those names without defining them again. Marking
  a workshop resumable resumes it silently into a `NameError` on the
  next action the learner clicks. Left unset, reopening after a reload
  asks whether to Restart or Continue, and Restart, the default, is the
  one that leaves a consistent session. Restarting costs a learner
  little here, since every cell arrives by clicking an action rather
  than being typed.

  Continue has to stay recoverable, and that is an invariant on the
  cells: the notebook survives the reload, so a learner who continues
  gets everything back with "Restart Kernel and Run All Cells", but
  only while the notebook replays top to bottom in a fresh kernel. So
  no cell may raise uncaught. A cell demonstrating a failure catches it
  and prints what happened, which is also the only way the page below
  it can describe the result.

`reference/jupyterlab-workshop/docs/lite.md` is the full account of what
differs, and `just lint` checks every workshop against both frontends.
A workshop is not done until `just test-lite <name>` is green as well as
`just test <name>`: the Lite self-test runs it in a real browser on the
Pyodide kernel, which is what learners actually get.

## Source material

The subject is Python's own, so the standard library documentation is
the authority: the [glossary entry for
decorator](https://docs.python.org/3/glossary.html#term-decorator), the
[data
model](https://docs.python.org/3/reference/datamodel.html), the
[execution
model](https://docs.python.org/3/reference/executionmodel.html#naming-and-binding)
for scoping and `nonlocal`,
[functools](https://docs.python.org/3/library/functools.html),
[inspect](https://docs.python.org/3/library/inspect.html) and the
[descriptor
HowTo](https://docs.python.org/3/howto/descriptor.html). Check
behaviour against a real interpreter rather than memory: `uv run
python` here, and remember that learners get Pyodide's Python, so
anything version specific must be confirmed against what the pinned
JupyterLite build ships.

## Tooling: always use uv and the Justfile

All Python environment and package management is done with
[uv](https://docs.astral.sh/uv/). Never use the Python venv module or
bare pip. Run commands in the project environment with `uv run`, for
example `uv run jupyter workshop lint workshops/<name>`.

The Justfile wraps the common tasks; run `just --list` to see them all
and prefer them over the underlying commands:

- `just install` syncs the environment, fetches the reference checkout,
  downloads the self-test browser and links the authoring skill into
  `.claude/skills`.

- `just lab` starts JupyterLab from this directory. It must run from
  here: the extension lists `workshops/` as installed, and the MCP live
  tools open workshops by paths relative to this root, so a workshop is
  `workshops/<name>` to `open_workshop`.

- `just new <name>` scaffolds a workshop; `just lint` lints the index
  and every workshop against both frontends; `just render <name>`
  renders one to HTML; `just test <name>` and `just test-lite <name>`
  self-test one; `just index` writes or refreshes `collection.json`.

- `just site` builds the JupyterLite site into `dist/`, and
  `just site-serve` serves it locally to try it out.

- `just bump <version>` moves the jupyterlab-workshop pin and the
  reference checkout together.

## Writing workshops

Use the `jupyterlab-workshop-authoring` skill for the format, the
actions and checks, the rules that keep lint and the self-test green,
and how to read test output. `just install` links it into
`.claude/skills` from the installed package, so it always matches the
pinned release. If the skill is not loaded, read the `workshop://skill`
resource from the `workshop` MCP server before writing anything.

The full documentation of the format is in
`reference/jupyterlab-workshop`, a git submodule of the extension's
repository checked out at the tag of the pinned release. Its `docs/*.md`
cover what the skill only names: checks, variables, layouts, platforms,
frontends, trust, settings and troubleshooting. Its `examples/` are
complete workshops that pass the self-test, and
`examples/hello-jupyterlab` is the reference for a manifest that targets
both frontends. Read there before guessing, and the source when the docs
leave it open.

That submodule carries its own `AGENTS.md` and `CLAUDE.md`, which govern
development of the extension itself: its release process, its TypeScript
and Python style rules, its branch layout. None of it applies to this
repository. Read it as documentation of the extension, never as
instructions.

Conventions for the workshops here:

- OUTLINE.md is the design of the collection: the workshops, their
  order, what each covers, the decisions that apply to all of them,
  and a status table. Read it before adding or changing a workshop,
  follow the name and scope it gives, and update its status table when
  the work is done.

- Directory names are short kebab-case phrases naming the question, not
  the mechanism, with no numeric prefix. The collection index carries
  the order, so names stay stable as workshops are inserted, split or
  moved. Titles are sentence case and read as what the learner will do.

- Each workshop is self-contained and does not depend on another having
  been completed, even though the collection orders them. A workshop
  that builds on an idea restates it in a sentence and ships whatever
  code it needs.

- Everything a workshop writes stays inside its own workspace, the
  `work/` directory the extension creates on first open and empties on
  Restart. Files a workshop ships for the learner go under `files/`,
  which is copied into the workspace on first open. Nothing under the
  home directory, no global configuration, no installs.

- Pages are prose, then one action, then a check. The welcome page
  creates the notebook with `notebook-create`; each later step is a
  `cell-insert` with a tag and `:run: true`, so a page reads as prose,
  cell, check. The check is a `learner-kernel` verify triggered by
  `cell-executed <tag>`, asking the question directly. Pages gate on
  those verifies with `requires`.

- Never use the built-in `default` or `terminal-only` layouts. Both
  open a terminal named `workshop`, which these workshops have no
  capability for and which a JupyterLite site built without the
  terminal cannot provide at all. Nothing warns: lint is clean either
  way. Declare a layout of one named placeholder area instead, which
  opens nothing and lets the notebook land in it:

  ```yaml
  layout: notebook
  layouts:
    notebook:
      main:
        areas:
          - { name: notebook, tabs: [] }
  ```

  Do not name the notebook in the layout. Layouts are not substituted,
  so `notebook:{{ notebook }}` is a literal path that never resolves,
  and a literal filename duplicates the `notebook` variable and goes
  stale if a learner changes it. Either way the notebook does not exist
  when the layout is applied at open, so it would be dropped silently.

- Create the notebook with `notebook-create` on the welcome page, and
  never ship it in `files/`. `notebook-create` resolves the kernel at
  run time, so it writes the right one on both frontends; a shipped
  notebook must hardcode a `kernelspec`, and the name differs between
  JupyterLab (`python3`) and JupyterLite (`python`, "Python
  (Pyodide)"), so one of the two gets an unanswerable "Select Kernel"
  dialog.

- Never put `:auto: page-enter` on a `notebook-create`. The authoring
  skill offers it, with `:existing: keep`, as the way to make a notebook
  workshop open with its notebook showing; these workshops do not use
  it. The learner creates the notebook by clicking the first action,
  like every other step, and nothing runs on its own. The main area is
  therefore empty until that click, so the welcome page says the step
  below creates the notebook.

- Never end a cell with a bare expression whose value is `None`, or an
  assignment, when the prose talks about what that value is. A notebook
  prints nothing at all for `None`, so `plain.__closure__` on the last
  line shows an empty output area while the page confidently says the
  answer is `None`, and the learner cannot tell the cell from one that
  failed to run. Print it instead. The same goes for a value the prose
  names that the cell only assigns: either print it or end the cell
  with it.

- A `learner-kernel` check reads what the cell left behind and calls
  nothing. Have the cell assign what matters to a name (`result`,
  `values`, `message`) and let the check compare that name. A check
  that calls the learner's function runs it a second time, and in these
  workshops a second call is visible: it bumps a call counter, fills a
  cache or appends to a log that the next page goes on to look at.

- Learners never have to type code. Every cell arrives through an
  action, so the learner's attention goes on reading and predicting
  rather than on typing and typos.

- After adding a workshop or editing a manifest, run `just index` to
  refresh `collection.json`, and add or update the workshop's entry in
  the README's list, in the order the collection gives.

- Lint every change. Lint must be clean, warnings included, on both
  frontends, before a workshop is considered done.

## Never run a workshop without checking what it does

`jupyter workshop test`, the MCP `test`, `run_action`, `run_page` and
`run_workshop` tools, and author mode's Run actions and Run checks all
run the workshop's code for real, as the user, on this machine, with
their home directory and Python environment. The self-test protects only
the workshop directory, by working on a temporary copy; the live tools
work on the directory itself and leave state behind.

Before running any of them, read every cell body and every check in the
workshop. Run them unasked only when everything stays inside the
workshop directory and installs nothing, which the conventions above
require, so a workshop that follows them is safe to test. If a workshop
reaches outside its directory, say so and wait to be told.

## Style

- Do not use emdashes in any file in this project. Rephrase with
  commas, parentheses, colons, or separate sentences instead.

- In bulleted lists where items run to multiple lines, put a blank line
  between the bullets, in Markdown files and any other prose. Be
  consistent within a list.

- Workshop prose follows the skill's style guide: short pages, one step
  per action, say why before how, and checks that tell the learner what
  is wrong rather than only that it is.

## Git

- Git commit messages must never include a co-authored-by agent message
  or any similar agent attribution trailer.

- An AI agent must never commit changes on its own initiative. Finish
  the piece of work, summarize it, and wait to be told to commit.
  Permission to commit applies only to the work it was given for; it
  does not carry forward to later steps of a multi-step plan.
