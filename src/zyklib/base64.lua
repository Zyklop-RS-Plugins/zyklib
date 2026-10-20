-- This module is a modified version of iskolbin's base64 version 1.5-3, which is
-- distributed by the copyright holder at https://github.com/iskolbin/lbase64 and
-- licensed under the 'unlicense' license to dedicate it to the public domain, which is reproduced below.
-- Any modifications performed to this module are licensed under the same license.

-- Public Domain (www.unlicense.org)
-- This is free and unencumbered software released into the public domain.
-- Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
-- software, either in source code form or as a compiled binary, for any purpose,
-- commercial or non-commercial, and by any means.
-- In jurisdictions that recognize copyright laws, the author or authors of this
-- software dedicate any and all copyright interest in the software to the public
-- domain. We make this dedication for the benefit of the public at large and to
-- the detriment of our heirs and successors. We intend this dedication to be an
-- overt act of relinquishment in perpetuity of all present and future rights to
-- this software under copyright law.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


--- Functions for encoding and decoding of [Base64](https://en.wikipedia.org/wiki/Base64) strings.
---
--- !doctype module
--- @class zyklib.base64
local base64 = {}

local extract = _G.bit32 and _G.bit32.extract -- Lua 5.2/Lua 5.3 in compatibility mode
if not extract then
  if _G.bit then                              -- LuaJIT
    local shl, shr, band = _G.bit.lshift, _G.bit.rshift, _G.bit.band
    extract = function(v, from, width)
      return band(shr(v, from), shl(1, width) - 1)
    end
  elseif _G._VERSION == "Lua 5.1" then
    extract = function(v, from, width)
      local w = 0
      local flag = 2 ^ from
      for i = 0, width - 1 do
        local flag2 = flag + flag
        if v % flag2 >= flag then
          w = w + 2 ^ i
        end
        flag = flag2
      end
      return w
    end
  else -- Lua 5.3+
    extract = load [[return function( v, from, width )
			return ( v >> from ) & ((1 << width) - 1)
		end]]()
  end
end


function base64.makeencoder(s62, s63, spad)
  local encoder = {}
  for b64code, char in pairs { [0] = 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',
    'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2',
    '3', '4', '5', '6', '7', '8', '9', s62 or '+', s63 or '/', spad or '=' } do
    encoder[b64code] = char:byte()
  end
  return encoder
end

function base64.makedecoder(s62, s63, spad)
  local decoder = {}
  for b64code, charcode in pairs(base64.makeencoder(s62, s63, spad)) do
    decoder[charcode] = b64code
  end
  return decoder
end

local encoder = base64.makeencoder()
local decoder = base64.makedecoder()

local char, concat = string.char, table.concat

--- Encodes a binary string as Base64.
--- @param data string Any binary data represented as a Lua string.
--- @param usecaching boolean? Whether to use caching for encoding. Defaults to false. Can improve or reduce performance depending on the data.
--- @return string # The Base64 encoding of the data.
function base64.encode(data, usecaching)
  local t, k, n = {}, 1, #data
  local lastn = n % 3
  local cache = {}
  for i = 1, n - lastn, 3 do
    local a, b, c = data:byte(i, i + 2)
    local v = a * 0x10000 + b * 0x100 + c
    local s
    if usecaching then
      s = cache[v]
      if not s then
        s = char(encoder[extract(v, 18, 6)], encoder[extract(v, 12, 6)], encoder[extract(v, 6, 6)],
          encoder[extract(v, 0, 6)])
        cache[v] = s
      end
    else
      s = char(encoder[extract(v, 18, 6)], encoder[extract(v, 12, 6)], encoder[extract(v, 6, 6)], encoder
        [extract(v, 0, 6)])
    end
    t[k] = s
    k = k + 1
  end
  if lastn == 2 then
    local a, b = data:byte(n - 1, n)
    local v = a * 0x10000 + b * 0x100
    t[k] = char(encoder[extract(v, 18, 6)], encoder[extract(v, 12, 6)], encoder[extract(v, 6, 6)], encoder[64])
  elseif lastn == 1 then
    local v = data:byte(n) * 0x10000
    t[k] = char(encoder[extract(v, 18, 6)], encoder[extract(v, 12, 6)], encoder[64], encoder[64])
  end
  return concat(t)
end

--- Decodes a Base64 string into its binary string representation.
--- @param data string A Base64 string.
--- @param usecaching boolean? Whether to use caching for decoding. Defaults to false. Can improve or reduce performance depending on the data.
--- @return string # The decoded Base64 string as binary data.
function base64.decode(data, usecaching)
  local pattern = '[^%w%+%/%=]'
  if decoder then
    local s62, s63
    for charcode, b64code in pairs(decoder) do
      if b64code == 62 then
        s62 = charcode
      elseif b64code == 63 then
        s63 = charcode
      end
    end
    pattern = ('[^%%w%%%s%%%s%%=]'):format(char(s62), char(s63))
  end
  data = data:gsub(pattern, '')
  local cache = usecaching and {}
  local t, k = {}, 1
  local n = #data
  local padding = data:sub(-2) == '==' and 2 or data:sub(-1) == '=' and 1 or 0
  for i = 1, padding > 0 and n - 4 or n, 4 do
    local a, b, c, d = data:byte(i, i + 3)
    local s
    if cache then
      local v0 = a * 0x1000000 + b * 0x10000 + c * 0x100 + d
      s = cache[v0]
      if not s then
        local v = decoder[a] * 0x40000 + decoder[b] * 0x1000 + decoder[c] * 0x40 + decoder[d]
        s = char(extract(v, 16, 8), extract(v, 8, 8), extract(v, 0, 8))
        cache[v0] = s
      end
    else
      local v = decoder[a] * 0x40000 + decoder[b] * 0x1000 + decoder[c] * 0x40 + decoder[d]
      s = char(extract(v, 16, 8), extract(v, 8, 8), extract(v, 0, 8))
    end
    t[k] = s
    k = k + 1
  end
  if padding == 1 then
    local a, b, c = data:byte(n - 3, n - 1)
    local v = decoder[a] * 0x40000 + decoder[b] * 0x1000 + decoder[c] * 0x40
    t[k] = char(extract(v, 16, 8), extract(v, 8, 8))
  elseif padding == 2 then
    local a, b = data:byte(n - 3, n - 2)
    local v = decoder[a] * 0x40000 + decoder[b] * 0x1000
    t[k] = char(extract(v, 16, 8))
  end
  return concat(t)
end

local CHUNK_SIZE = 192 * 1024

function base64.encodeLarge(data)
  local chunks = {}
  local n = #data

  for i = 1, n, CHUNK_SIZE do
    local chunk = data:sub(i, i + CHUNK_SIZE - 1)
    chunks[#chunks + 1] = base64.encode(chunk, false)
  end

  return table.concat(chunks)
end

local CHUNK_SIZE = 24 * 1024 -- Must be divisible by 4

---@param data string
---@return zyklib.async.Task<string>
function base64.decodeLargeAsync(data)
  local task = require("zyklib/async/Task")

  local t = task.new(function()
    local chunks = {}
    local count = 0
    local n = #data

    for i = 1, n, CHUNK_SIZE do
      count = count + 1

      chunks[count] = base64.decode(
        data:sub(i, i + CHUNK_SIZE - 1),
        false
      )

      log(i.."/"..n)

      task.maybeYield()
    end

    return table.concat(chunks)
  end)

  return t
end

return base64
