--- Helpers for reading bit sequences from integers.
---
--- !doctype module
--- @class zyklib.bits
local bits = {}

--- Gets a specific segment of bits from an integer.
--- @param stride integer The bit-width of the segment to extract
--- @param index integer The index of the segment to extract
--- @param value integer The integer to extract the segment from
--- @return integer # The extracted bit-sequence as an unsigned integer
function bits.get(stride, index, value)
  return (value >> (index * stride)) & ((1 << stride) - 1)
end

--- Splits the given integer value into an array of bit sequences.
--- @param stride integer The bit-width of each segment
--- @param value integer The integer to split into segments
--- @return integer[] # The extracted bit-sequence as an unsigned integer
function bits.getAll(stride, value, count)
  count = count or (32 // stride)

  local result = {}
  for i = 0, count - 1 do
    result[i + 1] = bits.get(stride, i, value)
  end
  return result
end

return bits
