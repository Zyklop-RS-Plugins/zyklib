local Event = require("zyklib/reactive/Event")
local lua_util = require("zyklib/lua_util")

--- @class zyklib.reactive.Observable<T> : zyklib.reactive.Event<{old: T, new: T}, nil>
--- @field subscribe fun(self: zyklib.reactive.Observable<T>, listener: fun(payload: {old: T, new: T}), start_suspended?: boolean): zyklib.reactive.EventHandler<{old: T, new: T}, nil>
--- @field subscribeSuspended fun(self: zyklib.reactive.Observable<T>, listener: fun(payload: {old: T, new: T})): zyklib.reactive.EventHandler<{old: T, new: T}, nil>
--- @field private value T
--- @field private equals fun(a: T, b: T): boolean
local Observable = {}
Observable.__index = Observable
setmetatable(Observable, { __index = Event })

--- @generic T
--- @param initial_value T
--- @param equals? fun(a: T, b: T): boolean
--- @param status_changed_callback fun(status: boolean)
--- @return zyklib.reactive.Observable<T>
function Observable.new(initial_value, equals, status_changed_callback)
  --- @type zyklib.reactive.Observable<T>
  local self = Event.new(status_changed_callback)
  setmetatable(self, Observable)

  self.value = initial_value
  self.equals = equals or lua_util.deep_equals

  return self
end

--- @generic T
--- @param self zyklib.reactive.Observable<T>
--- @return T
function Observable:get()
  return self.value
end

--- @generic T
--- @param self zyklib.reactive.Observable<T>
--- @param value T
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
