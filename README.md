# Python decorator workshops

[![Launch in your browser](https://img.shields.io/badge/launch-jupyterlite-F37626?logo=jupyter&logoColor=white)](https://grahamdumpleton.github.io/decorator-workshops/lab/index.html)
[![Launch on Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/GrahamDumpleton/decorator-workshops/main?urlpath=lab)
[![Open in GitHub Codespaces](https://img.shields.io/badge/launch-codespaces-579ACA?logo=github&logoColor=white)](https://codespaces.new/GrahamDumpleton/decorator-workshops?quickstart=1)
[![test](https://github.com/GrahamDumpleton/decorator-workshops/actions/workflows/test.yml/badge.svg)](https://github.com/GrahamDumpleton/decorator-workshops/actions/workflows/test.yml)

Nothing to install: start the workshops
[in your browser](https://grahamdumpleton.github.io/decorator-workshops/lab/index.html),
with no account and no server at all, or on
[mybinder.org](https://mybinder.org/v2/gh/GrahamDumpleton/decorator-workshops/main?urlpath=lab),
or in
[GitHub Codespaces](https://codespaces.new/GrahamDumpleton/decorator-workshops?quickstart=1)
with a GitHub account (see
[Launch in your browser](#launch-in-your-browser),
[Launch on Binder](#launch-on-binder) and
[Launch on Codespaces](#launch-on-codespaces) below). Or
[run them locally](#run-locally).

Guided, hands-on workshops that teach Python decorators, from what a
decorator is through to writing your own for functions, methods, classes
and coroutines, and knowing why each of them works.

The workshops run on
[jupyterlab-workshop](https://github.com/GrahamDumpleton/jupyterlab-workshop),
a JupyterLab extension that shows the instructions in a side panel with
clickable actions that drive the session, and checks what you have done
as you go. Each workshop is a directory of a `workshop.yaml` manifest
and Markdown pages.

Everything here is Python and its standard library, nothing to install,
so the workshops run in your browser with no server at all. See
[OUTLINE.md](OUTLINE.md) for the design of the collection.

## The workshops

Fourteen workshops, about three and a half hours in total, in the order
to take them.
Each is self-contained, so you can start anywhere, but they build.

**Understanding one**

1. **What a decorator does** (`what-a-decorator-does`, 10 minutes). Meet
   decorators as a user before writing one. Put `@functools.cache`,
   `@property` and `@dataclasses.dataclass` to work, watch each change
   what a function or a class does, and find out that the `@` line is
   shorthand for one ordinary line of Python.

2. **Your first decorator** (`your-first-decorator`, 20 minutes). Write
   the thing that goes after the `@`, by hand first and then with `@`.
   Build a timer, a call counter, and a decorator that stops the call
   happening at all, then find out why every one of them is wrong when
   the function raises, and what `try`/`finally` does about it.

3. **How a decorator remembers** (`how-a-decorator-remembers`,
   15 minutes). Find out how a wrapper still knows the function it wraps
   after the decorator has returned. Open a closure, look inside the
   cell, change a remembered value with `nonlocal`, and reproduce the
   late binding bug that catches everyone once.

**Getting it right**

4. **Decorators that take arguments** (`decorators-that-take-arguments`,
   15 minutes). Make a decorator work on any function with `*args` and
   `**kwargs`, add the extra layer that `@repeat(3)` needs, build a
   `@retry` that gives up loudly, and handle a decorator used with and
   without parentheses.

5. **Preserving the wrapped function**
   (`preserving-the-wrapped-function`, 10 minutes). See what a wrapper
   costs you, fix it with one line, and find out what `functools.wraps`
   really does, which is more than most advice claims.

6. **Stacking decorators** (`stacking-decorators`, 15 minutes). Two
   decorators, applied in one order and run in the other. Predict the
   nesting, watch a call travel in and out through both wrappers, and
   meet a stack where the order changes the answer rather than the
   output.

7. **Decorating methods** (`decorating-methods`, 15 minutes). The most
   common surprise in Python decorators. See which kinds keep working,
   read the error that names the wrong argument, find the instance in
   `args[0]`, and learn which way round to stack with `@staticmethod`
   and `@classmethod`.

8. **Decorators that are classes** (`class-based-decorators`,
   15 minutes). Keep state in an instance attribute, discover that the
   decorated function reports the decorator's own docstring, fix it with
   `functools.update_wrapper`, and see the one thing this kind cannot
   do.

**What else you can decorate**

9. **How methods bind** (`how-methods-bind`, 20 minutes). Do by hand
   what `obj.method` does for you, then give a class-based decorator a
   `__get__` so it finally works on methods, and find out why that fixes
   the binding but not the shared state. Ends with a descriptor that has
   nothing to do with decorators at all.

10. **Decorating classes** (`decorating-classes`, 15 minutes). Put a
    decorator on a class rather than a function. Synthesise a
    `__repr__`, add comparison and meet the hashing trap that comes with
    it, freeze a class against assignment, and find out what
    `@dataclass` has been doing since workshop one.

**Patterns worth knowing**

11. **Caching results** (`caching-results`, 15 minutes). Build the
    decorator from the first workshop. Watch recursive Fibonacci drop
    from 21891 calls to 21, break the cache key twice, fix it with
    `signature.bind`, then meet the memory leak that comes free with
    caching a method.

12. **Registering functions** (`registering-functions`, 15 minutes). A
    decorator that wraps nothing and hands the same object back. Build a
    command dispatcher, a route table and an event system, and recognise
    what Flask, Click and pytest have been doing all along.

13. **Retrying and handling errors** (`retrying-and-handling-errors`,
    15 minutes). Log a failure without swallowing it, translate an
    exception while keeping its cause, retry only what is worth
    retrying, and watch the stacking order decide what ends up in your
    logs.

14. **Decorating async functions** (`decorating-async-functions`,
    15 minutes). Put an ordinary decorator on an `async def` and watch
    it fail without saying so. Write a wrapper that awaits, one
    decorator that serves both kinds, and see what happens to an event
    loop when a wrapper blocks it.

## Launch in your browser

The collection is published as a
[JupyterLite](https://jupyterlite.readthedocs.io) site, which is
JupyterLab compiled to run entirely in the browser on a Python kernel
built to WebAssembly. There is no server and no account: the page is
static, and the Python runs in the tab. To start, click this link:

**[Launch the workshops in your browser](https://grahamdumpleton.github.io/decorator-workshops/lab/index.html)**

The first badge at the top of this page opens the same link. Python
itself is fetched when the page opens, so the first load takes a moment
and needs network access; after that the workshops run locally in the
tab. The workshop browser lists them numbered in the order to take them,
and the Finish dialog of each offers the next.

The site's own address is the whole link. The site carries the
collection index and is built subscribed to it, so the fourteen are
listed numbered in the collection's order, and with no one workshop to
open it starts in the workshop browser rather than at JupyterLab's
launcher. If you left a workshop open on an earlier visit, the link
takes you back to it; add JupyterLab's own `reset`, as in
`.../lab/index.html?reset`, to land in the workshop browser regardless.

A link can open one workshop directly, by name:

```
https://grahamdumpleton.github.io/decorator-workshops/lab/index.html?workshop=what-a-decorator-does
```

Add `restart=force` to start that workshop afresh every time the link is
opened, and JupyterLab's own `reset` to clear the window's tabs as well,
which is what a link for a talk or a class wants:

```
.../lab/index.html?reset&workshop=how-a-decorator-remembers&restart=force
```

Your work lives in the browser's own storage, so it survives a reload
but belongs to that browser, and clearing site data discards it.

The site reports progress to the workshops' own analytics service, as
the Binder and Codespaces sessions below do, under a token of its own,
labelled `decorator-lite`, which the service accepts from this site's
address and no other. There is no account, so nothing reported
identifies you, and nothing you type is sent. The welcome message the
site opens with, `lite/welcome.md`, says so before you start, and
`lite/settings.json` is the settings file the build puts into the site
to name the service.

The same settings file keeps the site to the workshops it was built
for, as the Binder and Codespaces sessions are kept: no opening other
directories or URLs, no subscribing to other collections or catalogs,
no removing and no editing. Restart puts a workshop back as it started.

Opening a workshop shows the trust dialog, as it does in a codespace or
a local install: what the workshop will do, which here is to write a
notebook and run cells in it, and how far to trust it. The kernel is
WebAssembly in the tab and the files it writes are the browser's, but
the tab is still on your network, so code running in it can send
requests to whatever your browser can reach, your local network
included. That is yours to allow, so the site does not decide it for
you. Choose Trust to let the actions run as intended; Restricted asks
before changing files or running code. You are asked once for each
workshop in that browser, and again only if the workshop changes.

The site is built and published by
[`.github/workflows/pages.yml`](.github/workflows/pages.yml), which runs
only after the test workflow has passed on `main`, so what is published
has been linted and self-tested on both frontends. `just site` builds
the same site locally, and `just site-serve` serves it to try out.

## Launch on Binder

[mybinder.org](https://mybinder.org) is a free public service that
builds this repository into a temporary JupyterLab and runs it for you
in the browser, so there is nothing to install. To start, click this
link:

**[Launch the workshops on Binder](https://mybinder.org/v2/gh/GrahamDumpleton/decorator-workshops/main?urlpath=lab)**

The badge at the top of this page opens the same link. Building and
starting the session takes a minute or two. When JupyterLab appears, the
workshops are listed in its workshop browser, numbered in the order to
take them, and the Finish dialog of each offers the next. Nothing is
installed for the workshops themselves: they are standard library only,
so the first page is ready as soon as the session is.

Opening a workshop locally shows a dialog asking you to trust it, since
its actions run code on your machine. On Binder that dialog is removed:
the session is a container of its own, created for you and discarded
when you are done, and at no time is anything done on your machine. The
`binder/postBuild` script installs a settings override that marks the
checkout's workshops as trusted, turns off editing, subscribes to the
checkout's own `collection.json`, and names `binder/welcome.md` as the
message shown when the session starts, which says what the workshops are
and how to end the session.

The same override names the workshops' own analytics service as the sink
for progress events, so a session reports which pages, actions and
checks happened and when, and it can be seen where the workshops are
clear and where they are not. Sessions are anonymous, and the events
never carry notebook contents, cell output or form answers; the welcome
message says that progress is reported before you start. The token in
the script is as public as the script, is accepted only for ingest, and
is labelled `decorator-binder` so it can be revoked on its own.

Binder sessions are temporary: anything you do in one is gone when it
ends, so finish a workshop in the session you started it in. When you
are done with the session, whether you finished a workshop or not, shut
it down rather than closing the browser tab, so the resources go back to
Binder for other users. The Finish dialog at the end of a workshop has a
button for this, and so does JupyterLab's File menu, under "Shut Down".

## Launch on Codespaces

[GitHub Codespaces](https://github.com/features/codespaces) builds this
repository into a container of your own in the cloud and opens it in VS
Code in the browser. It needs a GitHub account, and the codespace uses
your account's Codespaces allowance: personal accounts get a monthly
amount of use at no cost, beyond which GitHub charges for it or stops
it. Unlike a Binder session, a codespace is kept until you delete it. To
start, click this link:

**[Launch the workshops on Codespaces](https://codespaces.new/GrahamDumpleton/decorator-workshops?quickstart=1)**

The Codespaces badge at the top of this page opens the same link. If you
already have a codespace for this repository, the link offers to resume
it rather than create another.

Creating the codespace takes a few minutes. VS Code opens first, with
`.devcontainer/welcome.md` open in it, while `.devcontainer/setup.sh`
installs JupyterLab and the extension from `binder/requirements.txt`, as
`binder/postBuild` does, and `.devcontainer/start.sh` starts JupyterLab
in the background. When JupyterLab is ready, VS Code shows a
notification that the application on port 8888 is available: click Open
in Browser to open JupyterLab in a new tab. If the notification has
gone, open the address of the port labelled JupyterLab from VS Code's
Ports panel. The tab is not opened by itself, because browsers block a
tab nobody clicked for. From there the workshop browser lists the
workshops in order, as on Binder, and `setup.sh` installs the same
settings override as `binder/postBuild`, reporting progress to the same
analytics service under a token of its own, labelled
`decorator-codespaces`, with two differences: it names
`.devcontainer/welcome.md` as the message shown when JupyterLab starts,
and it does not mark the workshops as trusted.

On Binder the trust dialog is removed, because the session is an
anonymous container that is thrown away when you are done. A codespace
is yours, tied to your GitHub account, so opening a workshop shows the
trust dialog: what the workshop will do, which here is to write a
notebook and run cells in it, and how far to trust it. Choose Trust to
let its actions run as intended; Restricted asks before changing files
or running code. You are asked once for each workshop, and again only if
it changes. `.devcontainer/start.sh` also starts JupyterLab without the
codespace's GitHub credentials: the `GITHUB_TOKEN` variable is removed
from its environment and git is given no credential helper, so nothing a
workshop runs is handed a token for your account. That narrows what
workshop code can reach; it does not sandbox it.

JupyterLab in the codespace asks for no token, because the forwarded
port is private: only you, signed in to GitHub, can reach it. Leave the
port's visibility as Private. Made public, it would let anyone with its
address run code in your codespace.

A codespace stops by itself after a period of inactivity and keeps your
work, and starting it again from
[github.com/codespaces](https://github.com/codespaces) starts JupyterLab
again with it. A stopped codespace still uses your storage allowance, so
delete it there when you have finished with the workshops.

## Run locally

You need Python 3.14 and [uv](https://docs.astral.sh/uv/). Clone the
repository, install the environment and start JupyterLab from the
checkout:

```
git clone https://github.com/GrahamDumpleton/decorator-workshops
cd decorator-workshops
uv sync --no-dev
uv run jupyter lab --config=jupyter_lab_config.py
```

The config file opens JupyterLab on `collection.json`, so the workshop
browser lists the workshops numbered in the order to take them. Open the
first, and the Finish dialog at the end of each offers the next.

## What is in the repository

```
workshops/
  <name>/                a workshop: workshop.yaml and pages/*.md
collection.json          the index the workshop browser reads, written by `just index`
reference/jupyterlab-workshop
                         a git submodule of jupyterlab-workshop at the pinned release,
                         the full documentation and source of the workshop format
pyproject.toml           the uv project: JupyterLab and the extension, with the
                         authoring tools in the dev group
binder/                  the Binder image: the locked runtime dependencies exported
                         from uv.lock by `just requirements`, the Python version, the
                         postBuild that writes JupyterLab's settings, and the welcome
                         message a Binder session opens with
.devcontainer/           the Codespaces container: the same requirements installed with
                         pip, the settings, a script that starts JupyterLab on port
                         8888, and the welcome message VS Code opens
lite/                    the JupyterLite site's own files: the settings built into
                         the site, which keep it to these workshops and name the
                         analytics service, and the welcome message the site
                         opens with
.github/workflows/       CI: test.yml lints and self-tests every workshop on both
                         frontends, and pages.yml publishes the JupyterLite site to
                         GitHub Pages once test.yml has passed on main
jupyter_lab_config.py    opens a local JupyterLab on the collection, so the workshops
                         are listed in order; `just lab` passes it to jupyter lab
Justfile                 the common tasks; run `just` to list them
.mcp.json                the MCP server configuration for AI agent clients
AGENTS.md                guidance for AI agents writing workshops here
OUTLINE.md               the design of the collection: the workshops, what each
                         covers, and where each stands
```

## Writing and checking workshops

`just install` sets up the environment: it syncs uv, fetches the
reference submodule, downloads the browser the self-test drives, and
links the authoring skill shipped in the jupyterlab-workshop package
into `.claude/skills`.

```
just new <name>          scaffold a workshop under workshops/
just lint                lint collection.json and every workshop, on both frontends
just render <name>       render a workshop to HTML
just test <name>         self-test one workshop in JupyterLab
just test-lite <name>    self-test one workshop in JupyterLite
just index               write or refresh collection.json
just site                build the JupyterLite site into dist/
```
