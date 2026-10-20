# Getting Started

## Installation

Zyklib is a plain Lua source, so it has to be placed next to your plugin. Copy the
contents of `src/` into the root folder of your plugin, so that `zyklib.lua`
and the `zyklib/` folder sit alongside your `main.lua` and `plugin.json`.
This placement is important so that the internal `require` paths resolve
correctly.

```text
my_plugin/
  main.lua
  plugin.json
  zyklib.lua
  zyklib/
    array.lua
    reactive.lua
    reactive/
    ...
```

```{warning}
The exact placement of both zyklib.lua and the zyklib folder is important.
The Lua runtime embedded in the RuneScape client does support neither relative path requires nor `init.lua` requires for folders, so any other placement will break internal requires in zyklib.
```

See [Editor support](editor-support) to learn how to teach Zyklib typings to LuaLS.

## Usage

Require the library and use the modules it exposes:

```lua
local zyklib = require "zyklib"

local Event = zyklib.reactive.Event
local Highlight = zyklib.highlights.Highlight
```

You can also require a single module directly:

```lua
local base64 = require "zyklib/base64"
```

## Runtime setup

Zyklib contains a utility to turn the global `PluginShutdown` lifecycle function in an observable event. To set this up, manually call `zyklib.lifecycle.setupGlobals` once at startup of your plugin. You can then subscribe to the `shutdown_event` anywhere in your plugin to register cleanup code to be executed when the plugin shuts down.

```lua
local lifecycle = require "zyklib/lifecycle"

lifecycle.setupGlobals()

lifecycle.shutdown_event:subscribe(function()
  print("Shutting down")
end)
```

If your plugin already defines its own `PluginShutdown` function, call
`lifecycle.notifyShutdown()` from it instead.

(editor-support)=
## Editor support

To get completion and type checking with [LuaLS](https://luals.github.io/),
add the library to your `.luarc.json`:

```json
{
  "workspace.library": ["path/to/zyklib/src/"],
  "runtime.path": ["?.lua", "<path/to/zyklib>/src/?.lua"]
}
```
