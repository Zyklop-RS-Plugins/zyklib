local lua_util = {}

---@generic T
---@param list T[]
---@param predicate fun(value: T, index: integer): boolean
---@return T?
function lua_util.find(list, predicate)
  for i, value in ipairs(list) do
    if predicate(value, i) then
      return value
    end
  end

  return nil
end

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

---Concatenates multiple lists into a single list.
---@generic T
---@param ... T[] Lists to concatenate
---@return T[] Concatenated list
function lua_util.concat(...)
    local result = {}

    for _, t in ipairs({...}) do
        for _, v in ipairs(t) do
            result[#result + 1] = v
        end
    end

    return result
end

---Applies a function to each element of a list and returns a new list of the results.
---@generic T Original type of the list elements
---@generic U Target type of the list elements after applying the function
---@param list T[] The list to transform 
---@param func fun(value: T, index: integer): U The function to apply to each element of the list
---@return U[]
function lua_util.map(list, func)
  local result = {}
  for i, v in ipairs(list) do
    table.insert(result, func(v, i))
  end
  return result
end

---@generic T
---@param array T[]
---@param size integer
---@return T[][]
function lua_util.grouped(array, size)
    local chunks = {}

    for i = 1, #array, size do
        local group = {}

        for j = i, math.min(i + size - 1, #array) do
            group[#group + 1] = array[j]
        end

        chunks[#chunks + 1] = group
    end

    return chunks
end

return lua_util
