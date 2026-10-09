# Zyklib

Community maintained standard library for the RuneScape plugin API.

## How to use

### Installation

zyklib is plain Lua source, so it has to be placed next to your plugin. Copy the
contents of `src/` into the root folder of your plugin, so that `zyklib.lua` and the
`zyklib/` folder sit alongside your `main.lua` and `plugin.json`. This placement is important so that internal `require` paths resolve accurately:

```
my_plugin/
  main.lua
  plugin.json
  zyklib.lua
  zyklib/
    init.lua
    ...
```

When the library is included as a git submodule, copy `src/.` as part of your packaging step.

### Usage

> **Disclaimer:** zyklib does not have a stable API yet. Modules, functions and
> types may change or be removed at any time without notice. If you depend on it,
> pin a specific commit.

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

Available modules:

| Module                | Description                                                                                                                                   |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `lua_util`            | General Lua helpers                                                                                                                           |
| `reactive`            | Events and reactive values (`Event`, `EventHandler`, `Native`, `Observable`, `Derived`)                                                       |
| `api_util`            | Helpers for the RuneScape plugin API                                                                                                          |
| `MutableMesh`         | Mesh that can be modified after creation                                                                                                      |
| `UniqueNameGenerator` | Generates unique names                                                                                                                        |
| `base64`              | Base64 encoding and decoding                                                                                                                  |
| `highlights`          | Highlighting of locs, NPCs and terrain (`Highlight`, `HighlightGroup`, `HighlightParams`, `LocHighlight`, `NpcHighlight`, `TerrainHighlight`) |
| `bit`                 | Bit operations                                                                                                                                |

### Editor support

To get completion and type checking with [LuaLS](https://luals.github.io/), add the
library to your `.luarc.json`:

```json
{
  "workspace.library": ["path/to/zyklib/src/"],
  "runtime.path": ["?.lua", "?/init.lua", "path/to/zyklib/src/?.lua", "path/to/zyklib/src/?/init.lua"]
}
```

