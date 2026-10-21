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

--- Creates a shallow copy of a table. Keys and values are copied as-is, so nested tables are shared with the original.
--- The metatable is preserved. Non-table values are returned unchanged.
--- @generic T
--- @param value T
--- @return T
function objects.clone(value)
  if type(value) ~= "table" then
    return value
  end

  local result = {}

  for k, v in pairs(value) do
    result[k] = v
  end

  return setmetatable(result, getmetatable(value))
end

--- Creates a deep copy of a table, recursively copying all nested tables (both keys and values).
--- Shared and cyclic references within the original are preserved in the copy. Metatables are preserved but not copied.
--- Non-table values are returned unchanged.
--- @generic T
--- @param value T
--- @return T
function objects.deepClone(value)
  local copies = {}

  local function copy(v)
    if type(v) ~= "table" then
      return v
    end

    if copies[v] then
      return copies[v]
    end

    local result = {}
    copies[v] = result

    for key, inner in pairs(v) do
      result[copy(key)] = copy(inner)
    end

    return setmetatable(result, getmetatable(v))
  end

  return copy(value)
end

return objects
