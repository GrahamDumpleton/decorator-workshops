#!/bin/bash
# Run once when the codespace is created. Does what the Binder postBuild
# does, in the codespace: installs JupyterLab and the extension from the
# same pinned requirements the Binder image uses, and writes the
# JupyterLab overrides, with two differences, both because a codespace
# belongs to the person who created it, tied to their GitHub account, and
# persists, where a Binder session is an anonymous, temporary container.
# The welcome message is the Codespaces one. And workshops are not forced
# to trusted, so the learner is shown what a workshop asks to do and
# decides before it runs anything in their codespace. pip rather than uv,
# as on Binder, since this is the learner's environment. The analytics
# setting is Binder's: it reports every session's progress events to
# the sink the collection.json analytics block names, without asking,
# and the welcome message says so; the events say they came from a
# codespace.
#
# The workshops install nothing of their own: they are standard library
# only, with no environment key and no requirements, so there is no
# wheelhouse to fill and this is the whole of the setup.
# The second block is JupyterLab's own: it turns off the question about
# fetching Jupyter news, which would otherwise come before the welcome
# message the first time the codespace's JupyterLab opens.
set -euo pipefail

cd "$(dirname "$0")/.."

python -m pip install --no-cache-dir -r binder/requirements.txt

# The overrides live in JupyterLab's application settings directory. Ask
# JupyterLab for it rather than assuming the Python prefix: it moves to
# the user's home for a user-level install, which pip falls back to when
# the prefix is not writable, and to /usr/local/share for some system
# installs. sudo covers a directory this user cannot write.
settings="$(python -c 'import os; from jupyterlab.commands import get_app_dir; print(os.path.join(get_app_dir(), "settings"))')"

overrides="$(mktemp)"

cat > "$overrides" <<'JSON'
{
  "@jupyterlab-workshop/labextension:panel": {
    "defaultWorkshop": "",
    "browseOnStart": true,
    "workshopsDirectory": "workshops",
    "collections": ["collection.json"],
    "welcome": ".devcontainer/welcome.md",
    "disabledFeatures": [
      "open-directory",
      "open-url",
      "collections",
      "catalogs",
      "remove",
      "author"
    ],
    "analytics": { "report": "always" }
  },
  "@jupyterlab/apputils-extension:notification": {
    "fetchNews": "false"
  }
}
JSON

if mkdir -p "$settings" 2>/dev/null && [ -w "$settings" ]; then
  install -m 644 "$overrides" "$settings/overrides.json"
else
  sudo mkdir -p "$settings"
  sudo install -m 644 "$overrides" "$settings/overrides.json"
fi

rm -f "$overrides"

echo "Wrote the JupyterLab overrides to $settings/overrides.json"
