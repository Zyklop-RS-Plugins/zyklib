Getting Started
===============

Installation
------------

Zyklib is plain Lua source, so it has to be placed next to your plugin. Copy the
contents of ``src/`` into the root folder of your plugin, so that ``zyklib.lua``
and the ``zyklib/`` folder sit alongside your ``main.lua`` and ``plugin.json``.
This placement is important so that the internal ``require`` paths resolve
correctly::

   my_plugin/
     main.lua
     plugin.json
     zyklib.lua
     zyklib/
       array.lua
       reactive.lua
       reactive/
       ...

When the library is included as a git submodule, copy ``src/.`` as part of your
packaging step.

Usage
-----

Require the library and use the modules it exposes:

.. code-block:: lua

   local zyklib = require "zyklib"

   local Event = zyklib.reactive.Event
   local Highlight = zyklib.highlights.Highlight

You can also require a single module directly:

.. code-block:: lua

   local base64 = require "zyklib/base64"

A first example
---------------

.. code-block:: lua

   local array = require "zyklib/array"

   local numbers = { 1, 2, 3, 4, 5 }

   local evens = array.filter(numbers, function(n) return n % 2 == 0 end)
   local doubled = array.map(evens, function(n) return n * 2 end)
   -- doubled == { 4, 8 }

Plugin shutdown
---------------

Zyklib can notify you when the plugin shuts down. Call
``zyklib.lifecycle.setupGlobals`` once at startup and subscribe to the
shutdown event:

.. code-block:: lua

   local lifecycle = require "zyklib/lifecycle"

   lifecycle.setupGlobals()

   lifecycle.shutdown_event:subscribe(function()
     print("Shutting down")
   end)

If your plugin already defines its own ``PluginShutdown`` function, call
``lifecycle.notifyShutdown()`` from it instead.

Editor support
--------------

To get completion and type checking with `LuaLS <https://luals.github.io/>`_,
add the library to your ``.luarc.json``:

.. code-block:: json

   {
     "workspace.library": ["path/to/zyklib/src/"],
     "runtime.path": ["?.lua", "path/to/zyklib/src/?.lua"]
   }

.. warning::

   Zyklib does not have a stable API yet. Pin a specific commit.
