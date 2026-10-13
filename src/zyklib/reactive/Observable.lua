local Event = require("zyklib/reactive/Event")
local objects = require("zyklib/objects")

--- An observable represents a value that can be observed for changes.
--- Subscribers are notified whenever the value changes.
--- Every `Observable<T>` is an event of type `{old: T, new: T}`
--- @class zyklib.reactive.Observable<T> : zyklib.reactive.Event<{old: T, new: T}, nil>
--- @field subscribe fun(self: zyklib.reactive.Observable<T>, listener: fun(payload: {old: T, new: T}), start_suspended?: boolean): zyklib.reactive.EventHandler<{old: T, new: T}, nil>
--- @field subscribeSuspended fun(self: zyklib.reactive.Observable<T>, listener: fun(payload: {old: T, new: T})): zyklib.reactive.EventHandler<{old: T, new: T}, nil>
--- @field private value T
--- @field private equals fun(a: T, b: T): boolean
local Observable = {}
Observable.__index = Observable
setmetatable(Observable, { __index = Event })

--- Creates a new observable holding `initial_value`.
--- @generic T
--- @param initial_value T The initial value of the observable
--- @param equals? fun(a: T, b: T): boolean Optional equality function to compare old and new values
--- @param status_changed_callback fun(status: boolean) # Callback invoked when the status of the observable changes
--- @return zyklib.reactive.Observable<T>
function Observable.new(initial_value, equals, status_changed_callback)
  --- @type zyklib.reactive.Observable<T>
  local self = Event.new(status_changed_callback)
  setmetatable(self, Observable)

  self.value = initial_value
  self.equals = equals or objects.deepEquals

  return self
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

  if self.equals(old, value) then
    return
  end

  self.value = value

  self:trigger({
    old = old,
    new = value,
  })
end

return Observable
