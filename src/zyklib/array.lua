---Utilities for working with Lua arrays (sequences with integer keys starting at 1).
---
---!doctype module
---@class zyklib.array
local array = {}

---Finds an element in a list according to a predicate
---@generic T Element Type
---@param list T[]
---@param predicate fun(value: T, index: integer): boolean
---@return T? # The first matching element, or `nil` if there is none
---@return integer # Index of the matching element, or -1 if there is none
function array.find(list, predicate)
  for i, value in ipairs(list) do
    if predicate(value, i) then
      return value, i
    end
  end

  return nil, -1
end

---Checks whether a given element exists in a list
---@generic T
---@param list T[]
---@param element T
---@return boolean # `true` if the element is in the list
function array.includes(list, element)
  for i, value in ipairs(list) do
    if value == element then
      return true
    end
  end

  return false
end

---Concatenates multiple lists into a single list.
---@generic T
---@param ... T[] Lists to concatenate
---@return T[] # The concatenated list
function array.concat(...)
  local result = {}

  for _, t in ipairs({ ... }) do
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
---@return U[] # A new list containing the result of `func` for each element
function array.map(list, func)
  local result = {}
  for i, v in ipairs(list) do
    table.insert(result, func(v, i))
  end
  return result
end

---Splits a list into consecutive groups of a given size. The last group may be smaller if the list length is not a multiple of `size`.
---@generic T
---@param list T[] The list to split
---@param size integer Maximum number of elements per group
---@return T[][] # A list of groups
function array.grouped(list, size)
  local chunks = {}

  for i = 1, #list, size do
    local group = {}

    for j = i, math.min(i + size - 1, #list) do
      group[#group + 1] = list[j]
    end

    chunks[#chunks + 1] = group
  end

  return chunks
end

return array
