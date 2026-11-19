local api_util        = require "zyklib/api_util"
local Highlight       = require "zyklib/highlights/Highlight"
local HighlightParams = require "zyklib/highlights/HighlightParams"
local game_events     = require "zyklib/game_events"

--- @class zyklib.NpcHighlight : zyklib.Highlight
--- @field filter fun(npc: NPCEntity): boolean
--- @field render fun(npc: NPCEntity): ShapeListDrawSettings
--- @field active boolean
--- @field error_reported boolean? Whether a failure of this highlight was printed already
local NpcHighlight    = setmetatable({}, { __index = Highlight })
NpcHighlight.__index  = NpcHighlight

--- @type table<zyklib.NpcHighlight, boolean>
local instances       = {}
local instanceCount   = 0

--- Draws one highlight for an NPC, if its filter matches.
--- @param instance zyklib.NpcHighlight
--- @param npc NPCEntity
local function draw(instance, npc)
  if instance.filter(npc) then
    local settings = instance.render(npc)

    HighlightParams.apply_to_draw_call(instance.actual_params, settings)

    ShapeList.Draw(settings)
  end
end

--- @type zyklib.reactive.EventHandler
local draw_handler    = game_events.native.EntityDraw:subscribeSuspended(function(event)
  if (event.entityType ~= EntityType.NPC) then return true end
  local npc = event.npcEntity

  -- Ignore all NPCs without a display name. TODO: Is this sensible as a default?
  if npc.displayName == "" then return true end

  for instance in pairs(instances) do
    if instance.actual_params.visible ~= false then
      -- Protected per highlight, so a failing highlight neither stops the others nor keeps this handler from returning
      -- true. A failure is printed once, as this runs for every NPC on every frame.
      local ok, err = pcall(draw, instance, npc)
      if not ok and not instance.error_reported then
        instance.error_reported = true
        print("[zyklib] NpcHighlight failed, the affected NPCs are not highlighted: " .. tostring(err))
      end
    end
  end

  return true
end)

local function update_draw_handler()
  draw_handler:setSuspended(instanceCount == 0)
end

--- @param filter fun(npc: NPCEntity): boolean
--- @param render fun(npc: NPCEntity): ShapeListDrawSettings
--- @return zyklib.NpcHighlight
function NpcHighlight.new(filter, render)
  --- @type zyklib.NpcHighlight
  local self = setmetatable({}, NpcHighlight)
  self:init()
  self.filter = filter
  self.render = render
  self.active = false

  return self
end

--- Deactivates this NPC highlight and removes it from the list of active highlights. This will stop it from being drawn.
--- @return self
function NpcHighlight:deactivate()
  if self.active then
    self.active = false
    instances[self] = nil
    instanceCount = instanceCount - 1

    update_draw_handler()
  end

  return self
end

--- Activates this NPC hightlight and adds it to the list of active highlights. This will cause it to be drawn.
--- @return self
function NpcHighlight:activate()
  if not self.active then
    self.active = true
    instances[self] = true
    instanceCount = instanceCount + 1

    update_draw_handler()
  end

  return self
end

return NpcHighlight
