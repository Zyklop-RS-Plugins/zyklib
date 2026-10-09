local Ewent = require "zyklib/ewent/Ewent"
local UniqueNameGenerator = require "zyklib/UniqueNameGenerator"

local handler_name_generator = UniqueNameGenerator.new("api_util_handler_")

---Create a new event specifically for game events.
---@generic T, RetT
---@param game_event EventSubscription<T, RetT>
---@return zyklib.Ewent<T, RetT>?
local function forNativeGameEvent(game_event)
  ---@type string?
  local active_native_listener = nil

  ---@type zyklib.Ewent
  local ewent

  -- We need to separate declaration and assignment so that ewent is properly in scope for the callback function.

  ewent = Ewent.new(function(status)
    if status and not active_native_listener then
      active_native_listener = handler_name_generator:next()

      game_event.Subscribe(active_native_listener, function(payload)
        return ewent:trigger(payload)
      end)
    elseif (not status) and active_native_listener ~= nil then
      game_event.Unsubscribe(active_native_listener)
      active_native_listener = nil
    end
  end)

  return ewent
end

return {
  Logic = forNativeGameEvent(Event.Logic),
  ServerLogic = forNativeGameEvent(Event.ServerLogic),
  Draw = forNativeGameEvent(Event.Draw),
  OptionalDependencyChanged = forNativeGameEvent(Event.OptionalDependencyChanged),
  KeyUp = forNativeGameEvent(Event.KeyUp),
  KeyDown = forNativeGameEvent(Event.KeyDown),
  KeyTyped = forNativeGameEvent(Event.KeyTyped),
  VarTransmit = forNativeGameEvent(Event.VarTransmit),
  ChatMessage = forNativeGameEvent(Event.ChatMessage),
  PlayerEntityAdded = forNativeGameEvent(Event.PlayerEntityAdded),
  PlayerEntityRemoved = forNativeGameEvent(Event.PlayerEntityRemoved),
  NPCEntityAdded = forNativeGameEvent(Event.NPCEntityAdded),
  NPCEntityRemoved = forNativeGameEvent(Event.NPCEntityRemoved),
  ObjStackEntityAdded = forNativeGameEvent(Event.ObjStackEntityAdded),
  ObjStackEntityRemoved = forNativeGameEvent(Event.ObjStackEntityRemoved),
  ObjStackEntityChanged = forNativeGameEvent(Event.ObjStackEntityChanged),
  WindowFocusChanged = forNativeGameEvent(Event.WindowFocusChanged),
  GameStateChanged = forNativeGameEvent(Event.GameStateChanged),
  EntityDraw = forNativeGameEvent(Event.EntityDraw),
  WindowSizeChanged = forNativeGameEvent(Event.WindowSizeChanged),
  SkillTransmit = forNativeGameEvent(Event.SkillTransmit),
  RunEnergyTransmit = forNativeGameEvent(Event.RunEnergyTransmit),
  RunWeightTransmit = forNativeGameEvent(Event.RunWeightTransmit),
  MiniMenuOpened = forNativeGameEvent(Event.MiniMenuOpened),
  MiniMenuClosed = forNativeGameEvent(Event.MiniMenuClosed),
  MiniMenuReady = forNativeGameEvent(Event.MiniMenuReady),
  MiniMenuEntryAdded = forNativeGameEvent(Event.MiniMenuEntryAdded),
  MiniMenuEntrySelected = forNativeGameEvent(Event.MiniMenuEntrySelected),
  LocAdded = forNativeGameEvent(Event.LocAdded),
  LocRemoved = forNativeGameEvent(Event.LocRemoved),
  LocCustomised = forNativeGameEvent(Event.LocCustomised),
  LocAnimation = forNativeGameEvent(Event.LocAnimation),
  InventoryAdded = forNativeGameEvent(Event.InventoryAdded),
  InventoryUpdated = forNativeGameEvent(Event.InventoryUpdated),
  InventoryRemoved = forNativeGameEvent(Event.InventoryRemoved),
  GrandExchangeOfferUpdated = forNativeGameEvent(Event.GrandExchangeOfferUpdated),
  WorldCreated = forNativeGameEvent(Event.WorldCreated),
  WorldUpdated = forNativeGameEvent(Event.WorldUpdated),
  RegionCreated = forNativeGameEvent(Event.RegionCreated),
  RegionUpdated = forNativeGameEvent(Event.RegionUpdated),
}
