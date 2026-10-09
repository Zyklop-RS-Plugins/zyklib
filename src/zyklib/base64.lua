local base64 = {}

---@type string
local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

---Encodes a binary string as Base64.
---@param data string
---@return string
function base64.encode(data)
  return ((data:gsub(".", function(x)
    local byte = x:byte()
    local bits = ""

    for i = 8, 1, -1 do
      bits = bits .. (byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0")
    end

    return bits
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(bits)
    if #bits < 6 then
      return ""
    end

    local value = 0

    for i = 1, 6 do
      if bits:sub(i, i) == "1" then
        value = value + 2 ^ (6 - i)
      end
    end

    return alphabet:sub(value + 1, value + 1)
  end) .. ({ "", "==", "=" })[#data % 3 + 1])
end

---Decodes a Base64 string into its binary string representation.
---@param data string
---@return string
function base64.decode(data)
  data = data:gsub("[^" .. alphabet .. "=]", "")

  return (data:gsub(".", function(x)
    if x == "=" then
      return ""
    end

    local value = alphabet:find(x, 1, true) - 1
    local bits = ""

    for i = 6, 1, -1 do
      bits = bits .. (value % 2 ^ i - value % 2 ^ (i - 1) > 0 and "1" or "0")
    end

    return bits
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(bits)
    if #bits ~= 8 then
      return ""
    end

    local value = 0

    for i = 1, 8 do
      if bits:sub(i, i) == "1" then
        value = value + 2 ^ (8 - i)
      end
    end

    return string.char(value)
  end))
end

return base64
