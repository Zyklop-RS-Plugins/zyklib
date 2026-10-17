--- Helpers for the player's equipment.
---
--- !doctype module
--- @class zyklib.game.equipment
local equipment = {}

--- @alias zyklib.game.EquipmentSlotId 1 | 2 | 3 | 4 | 5 | 6 | 8 | 10 | 11 | 13 | 14 | 18

--- @enum (key) zyklib.game.EquipmentSlotName
equipment.SLOTS = {
  HEAD = 1,
  CAPE = 2,
  NECK = 3,
  MAINHAND = 4,
  BODY = 5,
  OFFHAND = 6,
  LEGS = 8,
  HANDS = 10,
  FEET = 11,
  RING = 13,
  AMMO = 14,
  POCKET = 18,
}

--- @alias zyklib.game.EquipmentSlot zyklib.game.EquipmentSlotName | zyklib.game.EquipmentSlotId

--- @param slot zyklib.game.EquipmentSlot
--- @return zyklib.game.EquipmentSlotId
local function resolveSlotId(slot)
  if type(slot) == "string" then
    return equipment.SLOTS[slot]
  else
    return slot --[[@as zyklib.game.EquipmentSlotId]]
  end
end

--- Get the worn item in an equipment slot.
--- @param slot zyklib.game.EquipmentSlot
--- @return InvSlot?
function equipment.getSlot(slot)
  local wornInv = Inventory.Find(config.Inv.WORN)

  if wornInv.valid then
    return wornInv:GetSlot(resolveSlotId(slot))
  end

  return nil
end

--- Get the contents of an equipment slot as an observable value.
--- @param slot zyklib.game.EquipmentSlot
--- @return zyklib.reactive.Observable<InvSlot>?
function equipment.observableSlot(slot)
  local zyklib = require("zyklib")

  local slot_id = resolveSlotId(slot)

  return zyklib.game_events.native.InventoryUpdated
      :filter(function(payload)
        return payload.inv.id == config.Inv.WORN.id and zyklib.array.includes(payload.slotsUpdated, slot_id)
      end)
      :map(function()
        return equipment.getSlot(slot_id)
      end)
      :toObservable(equipment.getSlot(slot_id) --[[@as InvSlot]])
end

return equipment
