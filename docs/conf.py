# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

import os
import subprocess

project = 'zyklib'
copyright = '2026, Zyklop Marco'
author = 'Zyklop Marco'

# Read the Docs provides the version name (e.g. "latest", "stable" or a tag).
# Local builds fall back to `git describe` and finally to "dev".
def _detect_version() -> str:
    if version_from_env := os.environ.get("READTHEDOCS_VERSION"):
        return version_from_env

    try:
        return subprocess.run(
            ["git", "describe", "--tags", "--always", "--dirty"],
            capture_output=True, text=True, check=True, timeout=10,
        ).stdout.strip() or "dev"
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
}
html_static_path = ['_static']
html_css_files = ['custom.css']
