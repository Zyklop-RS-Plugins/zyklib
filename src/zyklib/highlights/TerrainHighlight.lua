local api_util = require("zyklib/api_util")
local Highlight = require "zyklib/highlights/Highlight"
local HighlightParams = require "zyklib/highlights/HighlightParams"
local ewent           = require "zyklib/ewent/init"

---@type table<zyklib.TerrainHighlight, boolean>
local pending_instances = {}

---@param self zyklib.TerrainHighlight
local function create_if_available(self)
  if not self.shape_created and api_util.bounds_available(self.bounds) then
    self.instance = api_util.unique_shape_instance(self.generator())
    HighlightParams.apply_to_shape_instance(self.actual_params, self.instance)
    self.shape_created = true
  end
end

---@class zyklib.TerrainHighlight : zyklib.Highlight
---@field bounds Rect Bounds in map square coordinate.
---@field generator fun(): ShapeData
---@field instance ShapeInstance?
---@field shape_created boolean
local TerrainHighlight = setmetatable({}, { __index = Highlight })
TerrainHighlight.__index = TerrainHighlight

---@param bounds Rect Bounds in map square coordinate.
---@param generator fun(): ShapeData
---@return zyklib.TerrainHighlight
function TerrainHighlight.new(
    bounds,
    generator
)
  ---@type zyklib.TerrainHighlight
  local self = setmetatable({}, TerrainHighlight)
  self:init()
  self.bounds = bounds
  self.generator = generator
  self.instance = nil
  self.shape_created = false

  return self
end

---Activates this TerrainHighlight so that it will be drawn. If the bounds are not yet available, it will be drawn as soon as they are.
---@return zyklib.TerrainHighlight
function TerrainHighlight:activate()
  create_if_available(self)

  if not self.shape_created then
    pending_instances[self] = true
  end

  return self
end

---Deactivates this TerrainHighlight so that it will no longer be drawn. The existing shape instance will be destroyed and will be recreated if the highlight is activated again.
---@return self
function TerrainHighlight:deactivate()
  if self.instance then
    self.instance:Destroy()
    self.instance = nil
    self.shape_created = false
  end

  pending_instances[self] = nil

  return self
end

function TerrainHighlight:propagate_param_change()
  Highlight.propagate_param_change(self) -- super call

  if self.instance then
    HighlightParams.apply_to_shape_instance(self.actual_params, self.instance)
  end
end

---@type zyklib.EwentHandler
local listener = ewent.Native.ServerLogic:subscribe(function()
  for instance, _ in pairs(pending_instances) do
    create_if_available(instance)

    if instance.shape_created then
      -- Remove completed instance to avoid unnecessary updates.
      pending_instances[instance] = nil
    end
  end
end)

return TerrainHighlight
