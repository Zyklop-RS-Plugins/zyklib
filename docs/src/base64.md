# base64

The `zyklib.base64` module encodes Lua strings as Base64 and decodes Base64
data back into a Lua string. Use it when binary data must be represented safely
as text, for example in JSON payloads or configuration values.

```lua
local encoded = zyklib.base64.encode("hello")
print(encoded) -- aGVsbG8=

local decoded = zyklib.base64.decode(encoded)
print(decoded) -- hello
```

Both functions operate on Lua strings, so `encode` also accepts binary data.

## API reference

```{lua:autoobject} zyklib.base64
:members:
```
