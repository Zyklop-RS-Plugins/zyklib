local api_util         = require "zyklib/api_util"
local Highlight        = require "zyklib/highlights/Highlight"
local HighlightParams  = require "zyklib/highlights/HighlightParams"
local game_events      = require "zyklib/game_events"
local errors           = require "zyklib/errors"

--- A LocHighlight is a highlight that is drawn for LocEntity objects. You can specify a filter to determine which LocEntity objects should be highlighted,
--- and a render function to determine how each LocEntity highlight should be drawn.
--- @class zyklib.LocHighlight : zyklib.Highlight
--- @field filter LocListFilterSettings
--- @field render fun(npc: LocEntity): ShapeListDrawSettings
--- @field instances table<LocEntity, {shape_instance: ShapeInstance}>
--- @field failed table<any, boolean> Locations whose render failed; skipped until they leave the filter
--- @field active boolean
local LocHighlight     = setmetatable({}, { __index = Highlight })
LocHighlight.__index   = LocHighlight

--- @type table<zyklib.LocHighlight, boolean>
local active_instances = {}
local instanceCount    = 0

--- @param err any
local function report_error(err)
  errors.report("LocHighlight failed, the affected locations are not highlighted", err)
end

--- Creates the ShapeInstance of one location.
--- @param instance zyklib.LocHighlight
--- @param loc LocEntity
--- @return {shape_instance: ShapeInstance}
local function create_entry(instance, loc)
  local settings = instance.render(loc)

  local shape_instance = api_util.unique_shape_instance(settings.shapeData)

  shape_instance:SetShapeData(settings.shapeData)
  HighlightParams.apply_to_shape_instance(instance.actual_params, shape_instance)

  if settings.translation ~= nil then
    shape_instance.translation = settings.translation
  end
  if settings.scale ~= nil then
    shape_instance.scale = settings.scale
  end
  if settings.colour ~= nil then
    shape_instance.colour = settings.colour
  end

  return { shape_instance = shape_instance }
end

--- Update the ShapeInstances for a given LocHighlight to synchronize existing ShapeEntities with the current set of LocEntity objects that match the filter.
--- This will create new ShapeInstances for newly matching LocEntity objects, and destroy ShapeInstances for LocEntity objects that no longer exist or match the filter.
--- A location whose render fails is reported once and skipped while it matches, instead of failing again on every tick.
--- @param instance zyklib.LocHighlight
local function update_instances(instance)
  local locs = instance.active and LocList.Filter(instance.filter) or {}

  local active_locs = {}

  for _, loc in ipairs(locs) do
    local loc_id = api_util.loc_identity(loc)
    active_locs[loc_id] = true

    if instance.instances[loc_id] == nil and not instance.failed[loc_id] then
      local ok, entry = pcall(create_entry, instance, loc)
      if ok then
        instance.instances[loc_id] = entry
      else
        instance.failed[loc_id] = true
        report_error(entry)
      end
    end
  end

  for loc_id, entry in pairs(instance.instances) do
    if not active_locs[loc_id] then
      entry.shape_instance:Destroy()
      instance.instances[loc_id] = nil
    end
  end

  -- Gone or deactivated: tried again should it match again.
  for loc_id in pairs(instance.failed) do
    if not active_locs[loc_id] then instance.failed[loc_id] = nil end
  end
end


--- @type zyklib.reactive.EventHandler
local draw_handler = game_events.native.ServerLogic:subscribe(function(event)
  for instance, _ in pairs(active_instances) do
    -- Protected per highlight, so one failing highlight doesn't stop the others from updating.
    local ok, err = pcall(update_instances, instance)
    if not ok then report_error(err) end
  end
end)

local function update_logic_hook()
  -- The draw_handler is always created at the start, so we only need to suspend or resume it.
  draw_handler:setSuspended(instanceCount == 0)
end

--- @param filter LocListFilterSettings The filter object that determines which LocEntity objects should be highlighted.
--- @param render fun(loc: LocEntity): ShapeListDrawSettings
--- @return zyklib.LocHighlight
function LocHighlight.new(filter, render)
  --- @type zyklib.LocHighlight
  local self = setmetatable({}, LocHighlight)
  self:init()
  self.filter = filter
  self.render = render
  self.instances = {}
  self.failed = {}
  self.active = false

  return self
end

--- Deactivates this LocHighlight and removes it from the list of active highlights. This will stop it from being drawn.
--- @return self
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

--- Activates this LocHighlight and adds it to the list of active highlights. This will cause it to be drawn.
--- Should the first update fail, the activation is undone before the error is raised again, so the highlight can't
--- stay registered without its owner having a reference to deactivate it.
--- @return self
function LocHighlight:activate()
  if not self.active then
    self.active = true
    active_instances[self] = true
    instanceCount = instanceCount + 1

    local ok, err = pcall(update_instances, self)
    if not ok then
      self.active = false
      active_instances[self] = nil
      instanceCount = instanceCount - 1
      pcall(update_instances, self) -- Inactive, this destroys the shapes created before the failure.
      error(err, 0)
    end

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
