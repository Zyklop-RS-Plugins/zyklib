# json

The `zyklib.json` module encodes Lua values as JSON and decodes JSON strings
back into Lua values. Use it when storing structured data or exchanging it with
an API that expects or serves JSON.

Lua tables with consecutive numeric keys are encoded as JSON arrays. Tables
with string keys are encoded as JSON objects. Values passed to `encode` must
not contain circular references, sparse arrays, or mixed key types.

```lua
local player = {
  name = "Beau",
  age = 12,
  wealth = false
}

local encoded = zyklib.json.encode(data)
-- {"name":"Beau","age":12,"wealth":false}

local decoded = zyklib.json.decode(encoded)
print(decoded.name) -- Beau
```

## API reference

```{lua:autoobject} zyklib.json
:members:
```
