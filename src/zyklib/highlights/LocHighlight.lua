local api_util         = require "zyklib/api_util"
local Highlight        = require "zyklib/highlights/Highlight"
local HighlightParams  = require "zyklib/highlights/HighlightParams"
local ewent            = require "zyklib/ewent/init"

--- A LocHighlight is a highlight that is drawn for LocEntity objects. You can specify a filter to determine which LocEntity objects should be highlighted,
--- and a render function to determine how each LocEntity highlight should be drawn.
---@class zyklib.LocHighlight : zyklib.Highlight
---@field filter LocListFilterSettings
---@field render fun(npc: LocEntity): ShapeListDrawSettings
---@field instances table<LocEntity, {shape_instance: ShapeInstance}>
---@field active boolean
local LocHighlight     = setmetatable({}, { __index = Highlight })
LocHighlight.__index   = LocHighlight

---@type table<zyklib.LocHighlight, boolean>
local active_instances = {}
local instanceCount    = 0

---Update the ShapeInstances for a given LocHighlight to synchronize existing ShapeEntities with the current set of LocEntity objects that match the filter.
---This will create new ShapeInstances for newly matching LocEntity objects, and destroy ShapeInstances for LocEntity objects that no longer exist or match the filter.
---@param instance zyklib.LocHighlight
local function update_instances(instance)
  local locs = instance.active and LocList.Filter(instance.filter) or {}

  local active_locs = {}

  local create_count = 0

  for _, loc in ipairs(locs) do
    active_locs[api_util.loc_identity(loc)] = true

    if instance.instances[api_util.loc_identity(loc)] == nil then
      create_count = create_count + 1
      local settings = instance.render(loc)

      local shape_instance = api_util.unique_shape_instance(settings.shapeData)

      shape_instance:SetShapeData(settings.shapeData)

      if settings.translation ~= nil then
        shape_instance.translation = settings.translation
      end
      if settings.scale ~= nil then
        shape_instance.scale = settings.scale
      end
      if settings.colour ~= nil then
        shape_instance.colour = settings.colour
      end

      instance.instances[api_util.loc_identity(loc)] = {
        shape_instance = shape_instance,
      }
    end
  end

  local destroy_count = 0
  for loc_id, entry in pairs(instance.instances) do
    if not active_locs[loc_id] then
      entry.shape_instance:Destroy()
      instance.instances[loc_id] = nil
      destroy_count = destroy_count + 1
    end
  end
end


---@type zyklib.EwentHandler
local draw_handler = ewent.Native.ServerLogic:subscribe(function(event)
  for instance, _ in pairs(active_instances) do
    update_instances(instance)
  end
end)

local function update_logic_hook()
  -- The draw_handler is always created at the start, so we only need to suspend or resume it.
  draw_handler:setSuspended(instanceCount == 0)
end

---@param filter LocListFilterSettings The filter object that determines which LocEntity objects should be highlighted.
---@param render fun(loc: LocEntity): ShapeListDrawSettings
---@return zyklib.LocHighlight
function LocHighlight.new(filter, render)
  ---@type zyklib.LocHighlight
  local self = setmetatable({}, LocHighlight)
  self:init()
  self.filter = filter
  self.render = render
  self.instances = {}
  self.active = false

  return self
end

---Deactivates this LocHighlight and removes it from the list of active highlights. This will stop it from being drawn.
---@return self
function LocHighlight:deactivate()
  if self.active then
    self.active = false
    active_instances[self] = nil
    instanceCount = instanceCount - 1

    update_instances(self)
    update_logic_hook()
  end

  return self
end

---Activates this LocHighlight and adds it to the list of active highlights. This will cause it to be drawn.
---@return self
function LocHighlight:activate()
  if not self.active then
    self.active = true
    active_instances[self] = true
    instanceCount = instanceCount + 1

    update_instances(self)
    update_logic_hook()
  end

  return self
end

function LocHighlight:propagate_param_change()
  Highlight.propagate_param_change(self) -- super call

  for _, instance in pairs(self.instances) do
    HighlightParams.apply_to_shape_instance(self.actual_params, instance.shape_instance)
  end
end

return LocHighlight
