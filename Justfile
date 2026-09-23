# Guided JupyterLab workshops on Python decorators. Run `just` to list targets.

collection_id := "grahamdumpleton.me/python-decorators"
collection_title := "Python decorator workshops"
collection_description := "Guided JupyterLab workshops that teach Python decorators: what they do, how to write them, and why they work. Standard library only, and they run in the browser."
collection_repo := "https://github.com/GrahamDumpleton/decorator-workshops"

# List available targets.
default:
    @just --list

# Set up the environment: sync uv, fetch the reference checkout, download the self-test browser, link the authoring skill.
install:
    uv sync
    git submodule update --init
    uv run playwright install chromium
    just skill

# The skill ships inside the jupyterlab-workshop package. Linking it into
# .claude/skills lets Claude Code load it without a copy in this repository,
# and it tracks the pinned release; rerun after bumping the version.
# Link the authoring skill from the installed package into .claude/skills.
skill:
    #!/usr/bin/env bash
    set -euo pipefail
    target=$(uv run python -c 'import jupyterlab_workshop, pathlib; print(pathlib.Path(jupyterlab_workshop.__file__).parent / "skills" / "jupyterlab-workshop-authoring")')
    mkdir -p .claude/skills
    ln -sfn "$target" .claude/skills/jupyterlab-workshop-authoring
    echo "Linked .claude/skills/jupyterlab-workshop-authoring -> $target"

# JupyterLab must run from this directory: the extension lists workshops/
# as installed, and the MCP live tools open workshops by paths relative
# to this root, such as workshops/<name>.
# Start JupyterLab from the checkout, listing the workshops in the collection's order.
lab *ARGS:
    uv run jupyter lab --config=jupyter_lab_config.py {{ARGS}}

# Scaffold a new workshop under workshops/; extra args go to `jupyter workshop init`.
new NAME *ARGS:
    uv run jupyter workshop init workshops/{{NAME}} {{ARGS}}

# Every workshop here targets JupyterLite as well as JupyterLab, so each
# is linted twice: once plainly, and once with the frontend that has no
# server, no subprocess and no python in the shell.
# Lint collection.json and every workshop, for both frontends, or only the workshops named.
lint *NAMES:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    names=({{NAMES}})
    if [ ${#names[@]} -eq 0 ]; then
        if [ -f collection.json ]; then
            uv run jupyter workshop lint collection.json
        fi
        dirs=(workshops/*/)
    else
        dirs=("${names[@]/#/workshops/}")
    fi
    if [ ${#dirs[@]} -eq 0 ]; then
        echo "No workshops under workshops/ yet"
        exit 0
    fi
    for dir in "${dirs[@]}"; do
        echo "== $dir"
        uv run jupyter workshop lint "$dir"
        uv run jupyter workshop lint "$dir" --frontend jupyterlite
    done

# Render one workshop as HTML to check what a page looks like; extra args go to `jupyter workshop render`.
render NAME *ARGS:
    uv run jupyter workshop render workshops/{{NAME}} {{ARGS}}

# The self-test runs the workshop's actions and checks for real, as you,
# on this machine; only the workshop directory is protected, by a
# temporary copy. Read the workshop first.
# Self-test one workshop in a JupyterLab of its own; extra args go to `jupyter workshop test`.
test NAME *ARGS:
    uv run jupyter workshop test workshops/{{NAME}} {{ARGS}}

# The JupyterLite self-test builds a site, serves it and drives it in a
# headless browser with the Pyodide kernel, which is the environment
# learners actually get. A workshop is not done until this is green too.
# Self-test one workshop in JupyterLite; extra args go to `jupyter workshop test`.
test-lite NAME *ARGS:
    uv run jupyter workshop test workshops/{{NAME}} --frontend jupyterlite {{ARGS}}

# Self-test every workshop on both frontends, writing a JUnit report for each.
test-all:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    for dir in workshops/*/; do
        name=$(basename "$dir")
        echo "== $dir (jupyterlab)"
        uv run jupyter workshop test "$dir" --junit "results-$name.xml"
        echo "== $dir (jupyterlite)"
        uv run jupyter workshop test "$dir" --frontend jupyterlite --junit "results-$name-lite.xml"
    done

# No workshop here uses a terminal, so the site is built without one,
# which also drops the build's need for node, npm and micromamba. The
# build carries collection.json in the site and subscribes to it there,
# so the workshop browser lists the workshops numbered in the
# collection's order, and with no one workshop to open the site starts
# in the browser. lite/settings.json is built into the site. It keeps a
# visitor to these workshops, disabling what the Binder and Codespaces
# settings disable, and names the analytics sink, under a token that
# only the published site's origin may post with, so a site served
# locally reports nothing, and lite/welcome.md is the message that tells
# a visitor so.
# Build the JupyterLite site into dist/, carrying every workshop.
site *ARGS:
    uv run jupyter workshop lite workshops/*/ --out dist --no-terminal --collection collection.json --settings lite/settings.json --welcome lite/welcome.md {{ARGS}}

# Build the JupyterLite site and serve it locally to try it out.
site-serve *ARGS:
    uv run jupyter workshop lite workshops/*/ --out dist --no-terminal --collection collection.json --settings lite/settings.json --welcome lite/welcome.md --serve {{ARGS}}

# The repository URL is given explicitly so the index does not depend on
# a git remote being configured in the checkout.
# Write or refresh collection.json, the index the workshop browser reads.
index:
    uv run jupyter workshop index workshops --id "{{collection_id}}" --title "{{collection_title}}" --description "{{collection_description}}" --repo "{{collection_repo}}" --ordered

# Binder installs from binder/requirements.txt, so it is the locked
# runtime set (no dev group) exported from uv.lock, and is regenerated
# whenever the lock changes.
# Relock and export the runtime dependencies to binder/requirements.txt.
requirements:
    uv lock
    uv export --no-dev --no-hashes --no-annotate -o binder/requirements.txt

# The extension's reference checkout is what agents read for the workshop
# format beyond the skill (docs/, examples/ and the source), so it is
# kept at the tag of the pinned release and moves with the pin.
# Pin a new jupyterlab-workshop release, relock, export, relink the skill and move the reference checkout.
bump VERSION:
    uv add "jupyterlab-workshop=={{VERSION}}"
    just requirements
    just skill
    git -C reference/jupyterlab-workshop fetch --tags
    git -C reference/jupyterlab-workshop checkout "{{VERSION}}"
    git add reference/jupyterlab-workshop

# A workshop's kernelspec is registered for the user, outside the
# checkout, so removing the environment directory leaves a kernel in
# the launcher that points at a Python that no longer exists. The prune
# unregisters only the workshop kernelspecs whose environment is gone.
# Remove what opening, running and publishing the workshops leaves behind, and the kernelspecs left pointing at removed environments.
clean:
    rm -rf workshops/*/_workshop workshops/*/work workshops/*/dist workshops/*/scratch
    rm -rf dist .jupyterlite.doit.db
    rm -f results-*.xml
    find . -type d -name .ipynb_checkpoints -not -path "./.venv/*" -exec rm -rf {} +
    find . -type d -name __pycache__ -not -path "./.venv/*" -not -path "./scratch/*" -exec rm -rf {} +
    uv run jupyter workshop kernels --prune

# Also remove the environment and the skill link; run `just install` afterwards.
distclean: clean
    rm -rf .venv .claude/skills/jupyterlab-workshop-authoring
    git submodule deinit -f reference/jupyterlab-workshop
