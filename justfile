docs_python := if os() == "windows" { "docs/.venv/Scripts/python.exe" } else { "docs/.venv/bin/python" }

docs: docs_venv
    {{docs_python}} -m sphinx -M html docs docs/_build -v -E

# Installs the docs requirements only when docs/requirements.txt has changed.
# The lua-ls submodule is installed in editable mode, so it always uses the checked-out version.
[private]
docs_venv:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ ! -e docs/lua-ls/pyproject.toml ]; then
      echo "docs/lua-ls submodule is not initialized. Run: git submodule update --init docs/lua-ls" >&2
      exit 1
    fi

    stamp="docs/.venv/.requirements-{{sha256_file("docs/requirements.txt")}}"

    if [ ! -e "$stamp" ]; then
      python -m venv docs/.venv
      {{docs_python}} -m pip install -r docs/requirements.txt
      rm -f docs/.venv/.requirements-*
      touch "$stamp"
    fi