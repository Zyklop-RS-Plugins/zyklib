local UniqueNameGenerator = require "zyklib/UniqueNameGenerator"

---Helpers for working with the plugin API.
---
---!doctype module
---@class zyklib.api_util
local api_util = {}

local shape_instance_name_generator = UniqueNameGenerator.new("shape_instance_")

---
---@param shape_data ShapeData?
---@return ShapeInstance
function api_util.unique_shape_instance(shape_data)
  local instance = ShapeList.CreateInstance(shape_instance_name_generator:next()) --[[@as ShapeInstance]]

  if shape_data ~= nil then
    instance:SetShapeData(shape_data)
  end

  return instance
end

---Creates a color value from red, green, blue, and alpha components
---@param r integer
---@param g integer
---@param b integer
---@param a integer
---@return ColourRGBA
function api_util.color_rgba(r, g, b, a)
  return (r & 0xFF) << 24 | (g & 0xFF) << 16 | (b & 0xFF) << 8 | (a & 0xFF)
end

---Extracts red, green, blue, and alpha components from a color value
---@param color ColourRGBA
---@return integer r
---@return integer g
---@return integer b
---@return integer a
function api_util.color_to_rgba(color)
  local r = (color >> 24) & 0xFF
  local g = (color >> 16) & 0xFF
  local b = (color >> 8) & 0xFF
  local a = color & 0xFF

  return r, g, b, a
end

---@param loc LocEntity
---@return integer
function api_util.loc_identity(loc)
  return ((loc.configID * 12800 + loc.coordGrid.x) * 12800 + loc.coordGrid.z) * 4 + loc.coordGrid.level
end

---Takes any value and turns it into a plain lua value.
---Particularly, this handles userdata values by calling all getter functions on the metatable and returning a table of the results.
---@param value userdata | table | boolean | number | string | nil
---@return table | boolean | number | string | nil
function api_util.to_plain_table(value)
  local value_type = type(value)

  -- Values directly supported by most serializers.
  if value_type == "nil"
      or value_type == "boolean"
      or value_type == "number"
      or value_type == "string"
  then
    return value
  end

  if value_type == "table" then
    local result = {}

    for key, child in pairs(value) do
      local plain_value = api_util.to_plain_table(child)

      result[key] = plain_value
    end

    return result
  end

  if value_type == "userdata" then
    local result = {}
    local metatable = getmetatable(value)

    for name, getter in pairs(metatable) do
      if type(name) == "string"
          and name:sub(1, 2) ~= "__"
          and type(getter) == "function"
      then
        -- Assumes getter functions are methods: getter(value).
        local ok, field_value = pcall(function()
          return value[name]
        end)

        if ok then
          result[name] = api_util.to_plain_table(field_value)
        end
      end
    end

    return result
  end

  return nil
end

---Resolves the ground height at a given coordinate, returning a Vector3 with the original x and z coordinates and the resolved y coordinate.
---@param coords CoordFine
---@param kind HeightOffsetType?
---@return Vector3
function api_util.resolve_ground_height(coords, kind)
  kind = kind or HeightOffsetType.GROUND_DECOR

  local height, success = World.GetGroundHeight(coords.level, coords.x, coords.z, kind)

  if not success then
    return Vector3.new(coords.x, coords.y, coords.z)
  end

  return Vector3.new(coords.x, height, coords.z)
end

---Checks whether a given rectangle of mapsquares (NOT tiles) has its ground height available.
---@param bounds Rect
---@return boolean
function api_util.bounds_available(bounds)
  if bounds == nil then return false end

  local _, a = World.GetGroundHeight(0, bounds.x * 64 * 512 + 256, bounds.y * 64 * 512 + 256)
  local _, b = World.GetGroundHeight(0, ((bounds.x + bounds.width) * 64 - 1) * 512 + 256,
    ((bounds.y + bounds.height) * 64 - 1) * 512 + 256)

  return a and b
end

---Create a bound rectangle from a set of tile coordinates. The rectangle will be the smallest rectangle that contains all tiles.
---@param tiles CoordGrid[]
---@return Rect
function api_util.map_square_rect_from_tiles(tiles)
  local min_x = math.huge
  local min_z = math.huge
  local max_x = -math.huge
  local max_z = -math.huge

  for _, sample in ipairs(tiles) do
    if sample.mapSquareX < min_x then min_x = sample.mapSquareX end
    if sample.mapSquareZ < min_z then min_z = sample.mapSquareZ end
    if sample.mapSquareX > max_x then max_x = sample.mapSquareX end
    if sample.mapSquareZ > max_z then max_z = sample.mapSquareZ end
  end

  local rec = Rect.new(min_x, min_z, max_x - min_x + 1, max_z - min_z + 1)

  return rec
end

return api_util
