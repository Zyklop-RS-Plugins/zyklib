# Promise

`zyklib.async.Promise` represents a value that may be fulfilled or rejected in
the future. Create a pending promise with `zyklib.async.Promise.new()`, then
settle it once with `resolve(value)` or `reject(reason)`.

Register handlers with `onSuccess`, `onFailure`, or `onCompletion`. A handler
registered while the promise is pending runs when it settles; a handler
registered after settlement runs immediately. Settlement and callbacks are
synchronous: promises do not schedule work or yield on their own.

```lua
local promise = zyklib.async.Promise.new()

promise
  :map(function(value)
    return value * 2
  end)
  :onSuccess(function(value)
    print(value)
  end)
  :onFailure(function(reason)
    log(reason)
  end)

promise:resolve(21)
```

## API reference

```{lua:autoobject} zyklib.async.Promise
:members:
```
