# disposable

The `zyklib.disposable` module provides utilities for managing the lifetime of resources that can be cleaned up, cancelled, stopped, or destroyed.
Examples include event handlers, shape highlights, UI windows, or concurrent tasks.
Any such object should implement the `zyklib.disposable.IDisposable` interface and be grouped together in a `zyklib.disposable.DisposableGroup` instance.


provides a common lifetime-management contract
for objects that hold resources or registrations which must be released
explicitly. Call `dispose()` when the object is no longer needed. Implementors
of `IDisposable` should make disposal idempotent, so callers can safely dispose
an object more than once.

## Usage

Use `DisposableGroup` to own several disposable objects and dispose them
together. Add each object with `add`, then dispose the group when its enclosing
operation finishes.

```lua
local group = zyklib.disposable.Group.new()
group:add(
  event1:subscribe(function(payload) ... end),
  zyklib.highlight.NpcHighlight.new(...),
)

-- Later, when the subscription and highlight are no longer required:
group:dispose()
```

For a class to be disposable mark it as a subclass for LuaLS (e. g `MyClass : zyklib.disposable.IDisposable`) and implement the `dispose()` method in an idempotent manner, i.e. so that repeated invocations.

For a single cleanup action that is not already represented by an object, use
`wrap` to create an `IDisposable` from a parameterless function.

```lua
group:add(zyklib.disposable.wrap(function()
  release_resource()
end))
```

## API reference

```{lua:autoobject} zyklib.disposable
:members:
```

## Implementations

The following is a not necessarily exhaustive list of classes that implement `zyklib.disposable.IDisposable`:

- `zyklib.disposable.DisposableGroup` disposes every disposable added to the
  group.
- `zyklib.reactive.EventHandler` cancels its associated event subscription.
- `zyklib.Highlight` deactivates the highlight so it is no longer displayed.