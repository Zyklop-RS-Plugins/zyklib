---General-purpose helpers for plain Lua values and tables.
---
---!doctype module
---@class zyklib.lua_util
local lua_util = {}

---Compares two plain lua values or tables for deep equality.
---@param a boolean|number|string|table
---@param b boolean|number|string|table
---@return boolean
function lua_util.deep_equals(a, b)
  if a == b then
    return true
  end

  if type(a) ~= "table" or type(b) ~= "table" then
    return false
  end

  for k, v in pairs(a) do
    if not lua_util.deep_equals(v, b[k]) then
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

---Creates a shallow copy of a table by copying all of its key-value pairs into a new table. Does not copy metatables or nested tables.
---@param orig  table
---@return table
function lua_util.shallow_copy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

return lua_util
