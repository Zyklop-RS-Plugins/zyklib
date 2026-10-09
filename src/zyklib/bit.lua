local bits = {}

function bits.get(stride, index, value)
  return (value >> (index * stride)) & ((1 << stride) - 1)
end

function bits.getAll(stride, value, count)
  count = count or (32 // stride)

  local result = {}
  for i = 0, count - 1 do
    result[i + 1] = bits.get(stride, i, value)
  end
  return result
end

return bits