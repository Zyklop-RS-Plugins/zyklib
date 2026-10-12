--- Utilities for working with standard Lua arrays (tables with integer keys starting at 1).
--- This is not a class, so all functions are free functions where the respective array needs to be passed manually as the first parameter.
---
--- !doctype module
--- @class zyklib.array
local array = {}

--- Finds an element in a array according to a predicate
--- @generic T Element type of the array
--- @param arr T[]
--- @param predicate fun(value: T, index: integer): boolean
--- @return T? # The first matching element, or `nil` if there is none
--- @return integer # Index of the matching element, or -1 if there is none
function array.find(arr, predicate)
  for i, value in ipairs(arr) do
    if predicate(value, i) then
      return value, i
    end
  end

  return nil, -1
end

--- Checks whether a given element exists in a array
--- @generic T Element type of the array
--- @param arr T[]
--- @param element T
--- @return boolean # `true` if the element is in the array, `false` otherwise
function array.includes(arr, element)
  return array.exists(arr, function(value) return value == element end)
end

--- Finds the index of the first occurence of an element in an array.
--- @generic T Element type of the array
--- @param arr T[] The array to search
--- @param element T The element to find
--- @return integer # Index of the element, or -1 if not found
function array.indexOf(arr, element)
  local _, i = array.find(arr, function(value) return value == element end)

  return i
end

--- Applies a function returning an array to each element and concatenates all resulting arrays into a single array.
--- @generic T Element type of the array
--- @generic U Element type of the arrays returned by the function
--- @param arr T[] The array to transform
--- @param func fun(value: T, index: integer): U[] The function to apply to each element of the array
--- @return U[] # A new array containing all elements of the arrays returned by `func`, in order
function array.flatMap(arr, func)
  return array.flatten(array.map(arr, func))
end

--- Checks whether at least one element of a array satisfies a predicate. Returns `false` for an empty array.
--- @generic T Element type of the array
--- @param arr T[] The array to check
--- @param predicate fun(value: T, index: integer): boolean The condition to test each element against
--- @return boolean # `true` if the predicate holds for at least one element, `false` otherwise
function array.exists(arr, predicate)
  local _, i = array.find(arr, predicate)
  return i >= 0
end

--- Checks whether all elements of a array satisfy a predicate. Returns `true` for an empty array.
--- @generic T Element type of the array
--- @param arr T[] The array to check
--- @param predicate fun(value: T, index: integer): boolean The condition to test each element against
--- @return boolean # `true` if the predicate holds for every element, `false` otherwise
function array.forAll(arr, predicate)
  -- forAll is implemented in terms of inverted exists.
  return not array.exists(arr, function(value, index) return not predicate(value, index) end)
end

--- Creates a new array containing only the elements that satisfy a predicate. The order of elements is preserved.
--- @generic T Element type of the array
--- @param arr T[] The array to filter
--- @param predicate fun(value: T, index: integer): boolean The condition an element must satisfy to be kept
--- @return T[] # A new array with the matching elements
function array.filter(arr, predicate)
  local result = {}

  for i, v in ipairs(arr) do
    if predicate(v, i) then
      result[#result + 1] = v
    end
  end

  return result
end

--- Concatenates multiple arrays into a single array.
--- @generic T Element type of the individual arrays
--- @param arr T[][] An array of arrays
--- @return T[] # The flattened array, where all original arrays are concatenated
function array.flatten(arr)
  local result = {}

  for _, t in ipairs(arr) do
    for _, v in ipairs(t) do
      result[#result + 1] = v
    end
  end

  return result
end

--- Applies a function to each element of a array and returns a new array of the results.
--- @generic T Element type of the array
--- @generic U Target type of the array elements after applying the function
--- @param arr T[] The array to transform
--- @param func fun(value: T, index: integer): U The function to apply to each element of the array
--- @return U[] # A new array containing the result of `func` for each element
function array.map(arr, func)
  local result = {}
  for i, v in ipairs(arr) do
    result[i] = func(v, i)
  end
  return result
end

--- Splits a array into consecutive groups of a given size. The last group may be smaller if the array length is not a multiple of `size`.
--- @generic T Element type of the array
--- @param arr T[] The array to split
--- @param size integer Maximum number of elements per group
--- @return T[][] # A array of groups
function array.grouped(arr, size)
  local chunks = {}

  for i = 1, #arr, size do
    local group = {}

    for j = i, math.min(i + size - 1, #arr) do
      group[#group + 1] = arr[j]
    end

    chunks[#chunks + 1] = group
  end

  return chunks
end

--- Counts the number of elements in an array that satisfy a predicate.
--- @generic T Element type of the array
--- @param arr T[] The array to count elements from
--- @param predicate fun(value: T, index: integer): boolean The condition an element must satisfy to be counted
--- @return integer # The number of elements satisfying the predicate
function array.count(arr, predicate)
  local count = 0
  for i = 1, #arr do
    if predicate(arr[i], i) then
      count = count + 1
    end
  end
  return count
end

--- Folds (reduces) an array from right to left using a binary function and an initial accumulator value.
--- @generic T Element type of the array
--- @generic U Type of the accumulator
--- @param arr T[] The array to fold
--- @param func fun(value: T, accumulator: U, index: integer): U The function to apply, taking the current accumulator, the current element, and its index
--- @param initial U The initial value of the accumulator
--- @return U # The final accumulated value
function array.foldRight(arr, func, initial)
  local acc = initial
  for i = #arr, 1, -1 do
    acc = func(arr[i], acc, i)
  end
  return acc
end

--- Folds (reduces) an array from left to right using a binary function and an initial accumulator value.
--- @generic T Element type of the array
--- @generic U Type of the accumulator
--- @param arr T[] The array to fold
--- @param func fun(accumulator: U, value: T, index: integer): U The function to apply, taking the current accumulator, the current element, and its index
--- @param initial U The initial value of the accumulator
--- @return U # The final accumulated value
function array.foldLeft(arr, func, initial)
  local acc = initial
  for i = 1, #arr do
    acc = func(acc, arr[i], i)
  end
  return acc
end

return array
