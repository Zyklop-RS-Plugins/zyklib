# Promise

A `zyklib.async.Promise` represents a value that may be fulfilled or rejected in
the future. Create a pending promise with `zyklib.async.Promise.new()`, then
settle it once with `resolve(value)` or `reject(reason)`.

Register handlers with `onSuccess`, `onFailure`, or `onCompletion`. A handler
registered while the promise is pending runs when it settles similar to event handlers; a handler
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

Promises can be awaited. Call `promise:await()` **while within a yieldable coroutine** to yield execution and resume it once the promise resolves.

```lua
zyklib.async.async(function () 
  local a = zyklib.http.get(Plugin.urls["cluetrainer"], "fileA"):await()
  local b = zyklib.http.get(Plugin.urls["cluetrainer"], "fileB"):await()
  local c = zyklib.http.get(Plugin.urls["cluetrainer"], "fileC"):await()
end)
```

```{warning}
At the time of writing this, there are several open bugs regarding coroutines in the RuneScape client leading to crashes.
```


## API reference

```{lua:autoobject} zyklib.async.Promise
:members:
```
