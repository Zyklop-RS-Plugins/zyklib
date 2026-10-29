local Event = require("zyklib/reactive/Event")
local objects = require("zyklib/objects")

--- An observable represents a value that can be observed for changes.
--- Subscribers are notified whenever the value changes.
--- Every `Observable<T>` is an event of type `{old: T, new: T}`
--- @class zyklib.reactive.Observable<T>
--- @field changed_event zyklib.reactive.Event<{old: T, new: T}, nil>
--- @field subscribe fun(self: zyklib.reactive.Observable<T>, listener: fun(payload: T), trigger_now?: boolean): zyklib.reactive.EventHandler<{old: T, new: T}, nil>
--- @field subscribeSuspended fun(self: zyklib.reactive.Observable<T>, listener: fun(payload: T)): zyklib.reactive.EventHandler<{old: T, new: T}, nil>
--- @field private value T
--- @field private equals fun(a: T, b: T): boolean
local Observable = {}
Observable.__index = Observable

--- Creates a new observable holding `initial_value`.
--- @generic T
--- @param initial_value T The initial value of the observable
--- @param equals (fun(a: T, b: T): boolean)? Optional equality function to compare old and new values
--- @param status_changed_callback fun(status: boolean)? # Callback invoked when the status of the observable changes
--- @return zyklib.reactive.Observable<T>
function Observable.new(initial_value, equals, status_changed_callback)
  --- @type zyklib.reactive.Observable<T>
  local self = Event.new(status_changed_callback)
  setmetatable(self, Observable)

  self.changed_event = Event.new(status_changed_callback)

  self.value = initial_value
  self.equals = equals or objects.deepEquals

  return self
end

--- Subscribes to value changes and activates the subscription immediately.
--- The listener receives the new value (not the `{old, new}` change record) every time the value changes.
---
--- @generic T
--- @param self zyklib.reactive.Observable<T>
--- @param listener fun(payload: T) Called with the new value on every change
--- @param trigger_now boolean? If `true`, the listener is additionally called once right away with the current value
--- @return zyklib.reactive.EventHandler<{ old: T, new: T }, nil> # Handler that can be used to cancel or suspend the subscription
function Observable:subscribe(listener, trigger_now)
  local handler = self:subscribeSuspended(listener)
  handler:resume()

  if trigger_now then
    listener(self.value)
  end

  return handler
end

--- Subscribes to value changes, but leaves the subscription suspended.
--- The listener is not called until `resume()` is called on the returned handler.
--- Like `subscribe`, the listener receives the new value rather than the `{old, new}` change record.
---
--- @generic T
--- @param self zyklib.reactive.Observable<T>
--- @param listener fun(payload: T) Called with the new value on every change while the handler is active
--- @return zyklib.reactive.EventHandler<{ old: T, new: T }, nil> # The suspended handler
function Observable:subscribeSuspended(listener)
  local handler = self.changed_event:subscribeSuspended(function(change)
    listener(change.new)
  end)

  return handler
end

--- @generic T
--- @param self zyklib.reactive.Observable<T>
--- @return T # The current value of the observable
function Observable:get()
  return self.value
end

--- @generic T
--- @param self zyklib.reactive.Observable<T>
--- @param value T # The new value of the observable
function Observable:set(value)
  local old = self.value

  if self.equals(old, value) then return end

  self.value = value

  self.changed_event:trigger({
    old = old,
    new = value,
  })
end

--- Creates a derived observable whose value is `mapper` applied to this observable's value.
--- The derived observable only listens to this one while it itself is being observed.
---
--- @generic T, U
--- @param self zyklib.reactive.Observable<T>
--- @param mapper fun(value: T): U Pure function computing the derived value
--- @return zyklib.reactive.Observable<U>
function Observable:map(mapper)
  ---@type zyklib.reactive.EventHandler
  local handler

  --- @type zyklib.reactive.Observable<U>
  local mapped = Observable.new(mapper(self:get()), nil, function(active)
    handler:setActive(active)
  end)

  mapped:set(mapper(self:get()))

  handler = self:subscribeSuspended(function(value)
    mapped:set(mapper(value))
  end)

  return mapped
end

return Observable
