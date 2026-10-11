--- General-purpose helpers for plain Lua values and tables.
---
--- !doctype module
--- @class zyklib.objects
local objects = {}

--- Compares two plain lua values or tables for deep equality.
--- @param a boolean|number|string|table
--- @param b boolean|number|string|table
--- @return boolean
function objects.deepEquals(a, b)
  if a == b then
    return true
  end

  if type(a) ~= "table" or type(b) ~= "table" then
    return false
  end

  for k, v in pairs(a) do
    if not objects.deepEquals(v, b[k]) then
      return false
    end
  end

  for k in pairs(b) do
    if a[k] == nil then
      return false
    end
  end

  return true
end

return objects
