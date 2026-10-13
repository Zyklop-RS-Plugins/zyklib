# bits

The `zyklib.bit` module extracts fixed-width bit fields from an integer. 
Use it to unpack values that store several small numbers in one integer, which is common in the game's `VarClient` variables.

For example, the following snippet reads the clientside state of the lockbox puzzle in master clues.

```lua
  local tiles = {    
      zyklib.array.flatten(
        { zyklib.bits.getAll(2, var.VarClient["TRAIL_LIGHTSOUT_CLIENT_1"].value, 16),
          zyklib.bits.getAll(2, var.VarClient["TRAIL_LIGHTSOUT_CLIENT_2"].value, 9) }
      )
  }
```

## API reference

```{lua:autoobject} zyklib.bits
:members:
```
