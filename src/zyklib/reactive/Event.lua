local EventHandler = require("zyklib/reactive/EventHandler")


---@field subscribe fun(self: zyklib.Event<T, RetT>, listener: (fun(payload: T): RetT), start_suspended: boolean?): zyklib.EventHandler<T, RetT>
---@field subscribeSuspended fun(self: zyklib.Event<T, RetT>, listener: (fun(payload: T): RetT)): zyklib.EventHandler<T, RetT>

---@class zyklib.Event<T, RetT>
---@field private listeners zyklib.EventHandler<T, RetT>[]
---@field private status_changed_callback fun(status: boolean)?
---@field private hasActiveListeners boolean
local Event        = {}
Event.__index      = Event

---@generic T, RetT
---@param status_changed_callback fun(hasActiveListeners: boolean)? A callback function that is called whenever the number of active listeners changes from 0 to more than zero or vice versa
---@return zyklib.Event<T, RetT>
function Event.new(status_changed_callback)
  local self = setmetatable({}, Event)
  self.listeners = {}
  self.status_changed_callback = status_changed_callback
  self.hasActiveListeners = false
  return self
end

---Subscribe to this event with the given listener.
---@generic T, RetT
---@param self zyklib.Event<T, RetT>
---@param listener fun(payload: T): RetT The function to call when the event is triggered.
---@param start_suspended boolean? Whether the subscription should start in a suspended state
---@return zyklib.EventHandler<T, RetT> The created event handler
function Event:subscribe(listener, start_suspended)
  local handler = EventHandler.new(listener, self)

  if not start_suspended then
    handler:resume()
  end

  return handler
end

---Subscribe to this event with the given listener.
---@generic T, RetT
---@param self zyklib.Event<T, RetT>
---@param listener fun(payload: T): RetT The function to call when the event is triggered.
---@return zyklib.EventHandler<T, RetT> handler The created event handler
function Event:subscribeSuspended(listener)
  return self:subscribe(listener, true)
end

--- DO NOT CALL this directly. Use zyklib.Event:subscribe instead.
---@generic T, RetT
---@param self zyklib.Event<T, RetT>
---@param handler zyklib.EventHandler<T, RetT> The event handler to add to this event
---@return zyklib.EventHandler<T, RetT> The added event handler
function Event:addHandler(handler)
  table.insert(self.listeners, handler)
  self:update_status()
  return handler
end

--- DO NOT CALL this directly. Use zyklib.EventHandler:suspend or zyklib.EventHandler:cancel instead.
---@generic T, RetT
---@param self zyklib.Event<T, RetT>
---@param handler zyklib.EventHandler<T, RetT> The event handler to remove from this event
function Event:removeHandler(handler)
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
---@param self zyklib.Event<T, RetT>
---@param payload T
---@return RetT
function Event:trigger(payload)
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
---@param self zyklib.Event<T, RetT>
function Event:update_status()
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
---@param self zyklib.Event<T, RetT>
---@param f fun(payload: T): boolean
---@return zyklib.Event<T, RetT>
function Event:filter(f)
  return self:derive(function(payload, emit)
    if f(payload) then
      emit(payload)
    end
  end)
end

---Create a mapped event that transforms the payload of this event using the given function.
---@generic T, RetT, TargetT
---@param self zyklib.Event<T, RetT>
---@param f fun(payload: T): TargetT
---@return zyklib.Event<TargetT, RetT>
function Event:map(f)
  return self:derive(function(payload, emit)
    emit(f(payload))
  end)
end

---Derive a new event from this event using the given function.
---@generic T, RetT, TargetT
---@param self zyklib.Event<T, RetT>
---@param f fun(payload: T, trigger_derived: (fun (payload: TargetT))) A function that takes the original payload and a function to trigger the derived event.
---@return zyklib.Event<TargetT, RetT> The filtered and mapped event
function Event:derive(f)
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

  derived_event = Event.new(function(status) handler:setSuspended(status) end)

  return derived_event
end

---Subscribe a listener that is called at most once.
---@generic T, RetT
---@param self zyklib.Event<T, RetT>
---@param listener fun(payload: T): RetT
---@return zyklib.EventHandler<T, RetT>
function Event:once(listener)
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
---@param self zyklib.Event<T, RetT>
---@param initial_value T
---@return zyklib.Observable<T>
function Event:toObservable(initial_value)
  local Observable = require("zyklib/reactive/Observable") -- Local require to avoid circular dependency

  ---@type zyklib.EventHandler
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

return Event
