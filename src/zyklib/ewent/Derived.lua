local Derived = {}

local Native = require "zyklib/ewent/Native"

---Creates an observable whose value is queried once every n client ticks. Usually derived from VarClient(s).
---@generic T The type of the observed value
---@param value_function fun():T The function that computes the current value of this observable, usually by checking the value(s) of one or more VarClient.
---@param tick_rate integer? How often the value for this observable should be queried. Given in client ticks. Defaults to 1.
function Derived.forClientVariables(value_function, tick_rate)
  tick_rate = tick_rate or 1

  return Native.Logic
      :filter(function(tick) return (tick.logicTick % (tick_rate or 1)) == 0 end)
      :map(function() return value_function() end)
      :toObservable(value_function())
end

---Construct an observable for any VarClient or VarPlayer variable.
---@param var VarPlayer The player variable to be observed. Must be a variable that is actually transmitted to the game client.
---@return zyklib.Observable
function Derived.forPlayerVariable(var)
  -- Determine the base variable if necessary
  local base_var = var.baseVar or var

  return Native.VarTransmit
      :filter(function(payload) return payload.var.id == base_var.id end) -- React on var transmits for the (base) variable
      :map(function() return var.value end)                               -- Query value of the variable
      :toObservable(var.value)
end

---Construct an observable for any VarClient or VarPlayer variable. See Derived.forPlayerVariable or Derived.forClientVariables for more detail
---@param var VarType
---@param tick_rate integer? How often the value for this observable should be queried. It is updated every n ticks. Only applies for VarClient variables.
---@return zyklib.Observable
function Derived.forVariable(var, tick_rate)
  if var.typeName == "VarClient" then
    return Derived.forClientVariables(function() return var.value end, tick_rate)
  elseif var.typeName == "VarPlayer" then
    return Derived.forPlayerVariable(var)
  else
    error("zyklib: trying to construct observable from unsupported variable type")
  end
end

---Creates an observable for a specific interface that can be subscribed to to be notified when the interface opens and closes.
---@param interface integer The id of the interface in question
---@return zyklib.Observable<ui.Interface?>
function Derived.interface(interface)
  -- TODO: Maybe it makes sense to memoize these internally.

  return Native.ServerLogic
      :map(function() return ui.Interfaces:GetInterface(interface) end) -- Query value of the variable
      :toObservable(ui.Interfaces:GetInterface(interface))
end

return Derived
