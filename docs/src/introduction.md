# Introduction

Zyklib is a community maintained standard library for the RuneScape plugin API.
It is plain Lua source code that is shipped together with your plugin. It
provides helpers that many plugins would otherwise end up writing themselves.

```{warning}
Zyklib does not have a stable API yet. Modules, functions and types may
change or be removed at any time without notice. If you depend on it, pin a
specific commit.
```

## Why a standard library?

While developing the first wave of plugins, it became apparent that there is a set of utilities that many plugins will end up reimplementing.
Zyklib is an attempt to provide a centralized repository for these utilities to simplify both plugin development and moderation.

## Design

- **Plain Lua.** There is no build step and no dependency besides the plugin
  API itself.
- **Typed.** All public functions and types are annotated for
  [LuaLS](https://luals.github.io/), so you get completion and type checking
  in your editor.
- **Modular.** Require everything through `zyklib` or load single modules
  such as `zyklib/base64` directly.

Continue with {doc}`getting_started` to add Zyklib to your plugin.
