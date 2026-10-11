# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'zyklib'
copyright = '2026, Zyklop Marco'
author = 'Zyklop Marco'

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
    "member-order": "alphabetical",
}
lua_ls_class_default_function_name = "new"
lua_ls_class_default_force_non_colon = True
lua_ls_apidoc_roots = {
    "zyklib": {
        "path": "src/zyklib",
        "options": {
            "undoc-members": "",
        },
        "format": "md",
    },
}
lua_ls_apidoc_separate_members = True

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'alabaster'
html_static_path = ['_static']
