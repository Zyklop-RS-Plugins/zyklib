# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

import os
import re
import subprocess

project = 'zyklib'
copyright = '2026, Zyklop Marco'
author = 'Zyklop Marco'

# Read the Docs provides the version name (e.g. "latest", "stable" or a tag).
# Local builds fall back to `git describe` and finally to "dev".
def _detect_version() -> str:
    if version_from_env := os.environ.get("READTHEDOCS_VERSION"):
        version_match = re.fullmatch(r"release/(\d+\.\d+\.\d+)", version_from_env)
        return version_match.group(1) if version_match else version_from_env

    try:
        detected_version = subprocess.run(
            ["git", "describe", "--tags", "--always", "--dirty"],
            capture_output=True, text=True, check=True, timeout=10,
        ).stdout.strip() or "dev"
        version_match = re.fullmatch(r"release/(\d+\.\d+\.\d+)", detected_version)
        return version_match.group(1) if version_match else detected_version
    except (OSError, subprocess.SubprocessError):
        return "dev"


release = _detect_version()
version = release

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ["sphinx_lua_ls", "myst_parser"]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', 'lua-ls/**', '.venv/**']

lua_ls_project_root = "../"
lua_ls_backend = "luals"
lua_ls_default_options = {
    "members": "",
    "undoc-members": "",
    "member-order": "groupwise",
    "annotate-require": "force",
    "require-separator": "/",
}
lua_ls_class_default_force_non_colon = True

lua_ls_apidoc_separate_members = True

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'shibuya'
toc_object_entries_show_parents = "hide"

html_theme_options = {
    "globaltoc_expand_depth": 2,
    "nav_socials": [
        {
            "name": "Codeberg",
            "url": "https://codeberg.org/ZyklopMarco/runescape-api-zyklib",
            "icon": "simple-icons:codeberg",
        },
    ],
}

_codeberg_user = "ZyklopMarco"
_codeberg_repo = "runescape-api-zyklib"
_codeberg_url = f"https://codeberg.org/{_codeberg_user}/{_codeberg_repo}"

html_context = {
    "codeberg_user": _codeberg_user,
    "codeberg_repo": _codeberg_repo,
    "codeberg_url": _codeberg_url,
    "source_edit_template": f"{_codeberg_url}/src/branch/main/docs/{{0}}",
}

html_sidebars = {
    "**": [
        "sidebars/localtoc.html",
        "sidebars/codeberg-card.html",
        "sidebars/edit-this-page.html",
    ],
}
html_static_path = ['_static']
html_css_files = ['custom.css']
