---Utilities for working with standard Lua arrays (tables with integer keys starting at 1).
---This is not a class, so all functions are free functions where the respective array needs to be passed manually as the first parameter.
---
---!doctype module
---@class zyklib.array
local array = {}

---Finds an element in a array according to a predicate
---@generic T Element type of the array
---@param self T[]
---@param predicate fun(value: T, index: integer): boolean
---@return T? # The first matching element, or `nil` if there is none
---@return integer # Index of the matching element, or -1 if there is none
function array.find(self, predicate)
  for i, value in ipairs(self) do
    if predicate(value, i) then
      return value, i
    end
  end

  return nil, -1
end

---Checks whether a given element exists in a array
---@generic T Element type of the array
---@param self T[]
---@param element T
---@return boolean # `true` if the element is in the array, `false` otherwise
function array.includes(self, element)
  return array.exists(self, function(value) return value == element end)
end

---Applies a function returning an array to each element and concatenates all resulting arrays into a single array.
---@generic T Element type of the array
---@generic U Element type of the arrays returned by the function
---@param self T[] The array to transform
---@param func fun(value: T, index: integer): U[] The function to apply to each element of the array
---@return U[] # A new array containing all elements of the arrays returned by `func`, in order
function array.flatMap(self, func)
  return array.flatten(array.map(self, func))
end

---Checks whether at least one element of a array satisfies a predicate. Returns `false` for an empty array.
---@generic T Element type of the array
---@param self T[] The array to check
---@param predicate fun(value: T, index: integer): boolean The condition to test each element against
---@return boolean # `true` if the predicate holds for at least one element, `false` otherwise
function array.exists(self, predicate)
  local _, i = array.find(self, predicate)
  return i >= 0
end

---Checks whether all elements of a array satisfy a predicate. Returns `true` for an empty array.
---@generic T Element type of the array
---@param self T[] The array to check
---@param predicate fun(value: T, index: integer): boolean The condition to test each element against
---@return boolean # `true` if the predicate holds for every element, `false` otherwise
function array.forAll(self, predicate)
  -- forAll is implemented in terms of inverted exists.
  return not array.exists(self, function(value, index) return not predicate(value, index) end)
end

---Creates a new array containing only the elements that satisfy a predicate. The order of elements is preserved.
---@generic T Element type of the array
---@param self T[] The array to filter
---@param predicate fun(value: T, index: integer): boolean The condition an element must satisfy to be kept
---@return T[] # A new array with the matching elements
function array.filter(self, predicate)
  local result = {}

  for i, v in ipairs(self) do
    if predicate(v, i) then
      result[#result + 1] = v
    end
  end

  return result
end

---Concatenates multiple arrays into a single array.
---@generic T Element type of the individual arrays
---@param self T[][] An array of arrays
---@return T[] # The flattened array, where all original arrays are concatenated
function array.flatten(self)
  local result = {}

  for _, t in ipairs(self) do
    for _, v in ipairs(t) do
      result[#result + 1] = v
    end
  end

  return result
end

---Applies a function to each element of a array and returns a new array of the results.
---@generic T Element type of the array
---@generic U Target type of the array elements after applying the function
---@param self T[] The array to transform
---@param func fun(value: T, index: integer): U The function to apply to each element of the array
---@return U[] # A new array containing the result of `func` for each element
function array.map(self, func)
  local result = {}
  for i, v in ipairs(self) do
    table.insert(result, func(v, i))
  end
  return result
end

---Splits a array into consecutive groups of a given size. The last group may be smaller if the array length is not a multiple of `size`.
---@generic T Element type of the array
---@param self T[] The array to split
---@param size integer Maximum number of elements per group
---@return T[][] # A array of groups
function array.grouped(self, size)
  local chunks = {}

  for i = 1, #self, size do
    local group = {}

    for j = i, math.min(i + size - 1, #self) do
      group[#group + 1] = self[j]
    end

    chunks[#chunks + 1] = group
  end

  return chunks
end

return array
