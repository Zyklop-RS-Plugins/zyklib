--- An event handler is a reference to an event callback function that can be paused, resumed, and cancelled.
--- @class zyklib.reactive.EventHandler<T, RetT> : zyklib.disposable.IDisposable
--- @field private listener_function fun(payload: T):RetT
--- @field private cancelled boolean
--- @field private suspended boolean
--- @field private event zyklib.reactive.Event<T>
local EventHandler = {}
EventHandler.__index = EventHandler

--- Creates a new event handler. Do not call this directly; use zyklib.reactive.Event:subscribe instead.
--- @param handler fun(payload: T):RetT The handler function
--- @param event zyklib.reactive.Event<T> The event this handler is associated with
--- @return zyklib.reactive.EventHandler<T, RetT>
function EventHandler.new(handler, event)
  local self = setmetatable({}, EventHandler)
  self.listener_function = handler
  self.cancelled = false
  self.suspended = true
  self.event = event
  return self
end

--- Notify this event handler with the given payload. Should only be called by the associated event.
--- @package
--- @param payload T The payload to pass to the event handler
--- @return RetT 
function EventHandler:notify(payload)
  return self.listener_function(payload)
end

--- @return boolean # Whether the event handler is active
function EventHandler:isActive()
  return not self.cancelled and not self.suspended
end

--- Permanently cancel this event subscription. No further event notifications will be received.
function EventHandler:cancel()
  if not self.cancelled then
    self:suspend()
    self.cancelled = true
    -- Clear reference to the event and the listener function to aid garbage collection in niche situations
    self.event = nil
    self.listener_function = nil
  end
end

--- Suspend this EventHandler. It is removed from the target event and will not receive events, but can be resumed later.
function EventHandler:suspend()
  self:setSuspended(true)
end

--- Resume this EventHandler if it was previously suspended.
function EventHandler:resume()
  self:setSuspended(false)
end

--- Set the suspended state of this EventHandler.
--- @param suspended boolean Whether this EventHandler should be suspended
function EventHandler:setSuspended(suspended)
  if self.cancelled then return end

  if suspended ~= self.suspended then
    self.suspended = suspended

    if suspended then
      self.event:removeHandler(self)
    else
      self.event:addHandler(self)
    end
  end
end

--- Set the suspended state of this EventHandler to the inverse of the given boolean
--- @param active boolean
function EventHandler:setActive(active)
  self:setSuspended(not active)
end

--- Disposing an EventHandler will cancel it.
function EventHandler:dispose()
  self:cancel()
end

return EventHandler
