local EwentHandler = require("zyklib/ewent/EwentHandler")

---@class zyklib.Ewent<T, RetT>
---@field private listeners zyklib.EwentHandler<T, RetT>[]
---@field private status_changed_callback fun(status: boolean)?
---@field private hasActiveListeners boolean
local Ewent        = {}
Ewent.__index      = Ewent

---@generic T, RetT
---@param status_changed_callback fun(hasActiveListeners: boolean)? A callback function that is called whenever the number of active listeners changes from 0 to more than zero or vice versa
---@return zyklib.Ewent<T, RetT>
function Ewent.new(status_changed_callback)
  local self = setmetatable({}, Ewent)
  self.listeners = {}
  self.status_changed_callback = status_changed_callback
  self.hasActiveListeners = false
  return self
end

---Subscribe to this event with the given listener.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
---@param listener fun(payload: T): RetT The function to call when the event is triggered.
---@param start_suspended boolean? Whether the subscription should start in a suspended state
---@return zyklib.EwentHandler<T, RetT> The created event handler
function Ewent:subscribe(listener, start_suspended)
  local handler = EwentHandler.new(listener, self)

  if not start_suspended then
    handler:resume()
  end

  return handler
end

---Subscribe to this event with the given listener.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
---@param listener fun(payload: T): RetT The function to call when the event is triggered.
---@return zyklib.EwentHandler<T, RetT> The created event handler
function Ewent:subscribeSuspended(listener)
  return self:subscribe(listener, true)
end

--- DO NOT CALL this directly. Use zyklib.Ewent:subscribe instead.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
---@param handler zyklib.EwentHandler<T, RetT> The event handler to add to this event
---@return zyklib.EwentHandler<T, RetT> The added event handler
function Ewent:addHandler(handler)
  table.insert(self.listeners, handler)
  self:update_status()
  return handler
end

--- DO NOT CALL this directly. Use zyklib.EwentHandler:suspend or zyklib.EwentHandler:cancel instead.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
---@param handler zyklib.EwentHandler<T, RetT> The event handler to remove from this event
function Ewent:removeHandler(handler)
  for i = #self.listeners, 1, -1 do
    if self.listeners[i] == handler then
      table.remove(self.listeners, i)
      self:update_status()
      break
    end
  end
end

---Trigger this event with the given payload.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
---@param payload T
---@return RetT
function Ewent:trigger(payload)
  local result_value = nil

  -- Snapshot the listeners so subscriptions/suspensions/cancellations
  -- during notification don't affect the current dispatch.
  for _, listener in ipairs({ table.unpack(self.listeners) }) do
    if listener:isActive() then
      result_value = listener:notify(payload)
    end
  end

  return result_value
end

---Update the status of this event, calling the status changed callback if the active listener state has changed.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
function Ewent:update_status()
  local hasActiveListeners = #self.listeners > 0
  if hasActiveListeners ~= self.hasActiveListeners then
    self.hasActiveListeners = hasActiveListeners
    if self.status_changed_callback then
      self.status_changed_callback(hasActiveListeners)
    end
  end
end

---Create a filtered event that only triggers when the given predicate function is true for a given event payload.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
---@param f fun(payload: T): boolean
---@return zyklib.Ewent<T, RetT>
function Ewent:filter(f)
  return self:derive(function(payload, emit)
    if f(payload) then
      emit(payload)
    end
  end)
end

---Create a mapped event that transforms the payload of this event using the given function.
---@generic T, RetT, TargetT
---@param self zyklib.Ewent<T, RetT>
---@param f fun(payload: T): TargetT
---@return zyklib.Ewent<TargetT, RetT>
function Ewent:map(f)
  return self:derive(function(payload, emit)
    emit(f(payload))
  end)
end

---Derive a new event from this event using the given function.
---@generic T, RetT, TargetT
---@param self zyklib.Ewent<T, RetT>
---@param f fun(payload: T, trigger_derived: (fun (payload: TargetT))) A function that takes the original payload and a function to trigger the derived event.
---@return zyklib.Ewent<TargetT, RetT> The filtered and mapped event
function Ewent:derive(f)
  local derived_event = nil

  local handler = self:subscribe(function(payload)
    local target_value = nil

    f(payload, function(target_payload)
      if derived_event ~= nil then
        target_value = derived_event:trigger(target_payload)
      end
    end)

    return target_value
  end)

  derived_event = Ewent.new(function(status) handler:setSuspended(status) end)

  return derived_event
end

---Subscribe a listener that is called at most once.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
---@param listener fun(payload: T): RetT
---@return zyklib.EwentHandler<T, RetT>
function Ewent:once(listener)
  local handler

  handler = self:subscribe(function(payload)
    handler:cancel()
    return listener(payload)
  end)

  return handler
end

--- Construct an observable from this event. The event payload will become the observable's value, and the observable will be updated whenever the event is triggered.
--- When the observable has no active listeners, the event listener will also be suspended.
---@generic T, RetT
---@param self zyklib.Ewent<T, RetT>
---@param initial_value T
---@return zyklib.Observable<T>
function Ewent:toObservable(initial_value)
  local Observable = require("zyklib/ewent/Observable") -- Local require to avoid circular dependency

  ---@type zyklib.EwentHandler
  local handler

  local observable = Observable.new(initial_value, nil, function(status)
    handler:setSuspended(not status)
  end)

  handler = self:subscribe(function(payload)
    observable:set(payload)
    return nil
  end)

  return observable
end

return Ewent
