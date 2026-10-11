Introduction
============

Zyklib is a community maintained standard library for the RuneScape plugin API.
It is plain Lua source code that is shipped together with your plugin. It
provides the helpers that most plugins end up writing themselves.

.. warning::

   Zyklib does not have a stable API yet. Modules, functions and types may
   change or be removed at any time without notice. If you depend on it, pin a
   specific commit.

What is in the box
------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Module
     - Description
   * - :doc:`lua_util`
     - General Lua helpers
   * - :doc:`array`
     - Helpers for Lua arrays (``find``, ``includes``, ``concat``, ``map``, ``grouped``, ...)
   * - :doc:`reactive`
     - Events and reactive values (``Event``, ``EventHandler``, ``Native``, ``Observable``, ``Derived``)
   * - :doc:`api_util`
     - Helpers for the RuneScape plugin API
   * - :doc:`MutableMesh`
     - Mesh that can be modified after creation
   * - :doc:`UniqueNameGenerator`
     - Generates unique names
   * - :doc:`base64`
     - Base64 encoding and decoding
   * - :doc:`highlights`
     - Highlighting of locs, NPCs and terrain
   * - :doc:`bit`
     - Bit operations
   * - :doc:`lifecycle`
     - Plugin lifecycle handling, such as shutdown notification
   * - :doc:`game`
     - Helpers for game concepts such as equipment

Design
------

* **Plain Lua.** There is no build step and no dependency besides the plugin
  API itself.
* **Typed.** All public functions and types are annotated for
  `LuaLS <https://luals.github.io/>`_, so you get completion and type checking
  in your editor.
* **Modular.** Require everything through ``zyklib`` or load single modules
  such as ``zyklib/base64`` directly.

Continue with :doc:`getting_started` to add Zyklib to your plugin.
