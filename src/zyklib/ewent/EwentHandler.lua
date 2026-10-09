---@generic T
---@generic RetT
---@class zyklib.EwentHandler<T, RetT>
---@field private listener_function fun(payload: T):RetT
---@field private cancelled boolean
---@field private suspended boolean
---@field private ewent zyklib.Ewent<T>
local EwentHandler = {}
EwentHandler.__index = EwentHandler

---Creates a new event handler. Do not call this directly; use zyklib.Ewent:subscribe instead.
---@param handler fun(payload: T):RetT The handler function
---@param ewent zyklib.Ewent<T> The event this handler is associated with
---@return zyklib.EwentHandler<T, RetT>
function EwentHandler.new(handler, ewent)
  local self = setmetatable({}, EwentHandler)
  self.listener_function = handler
  self.cancelled = false
  self.suspended = true
  self.ewent = ewent
  return self
end

---Notify this event handler with the given payload.
---@param payload T
---@return RetT
function EwentHandler:notify(payload)
  return self.listener_function(payload)
end

---@return boolean isActive Whether the event handler is active
function EwentHandler:isActive()
  return not self.cancelled
end

---Permanently cancel this event subscription. No further event notifications will be received.
function EwentHandler:cancel()
  if not self.cancelled then
    self:suspend()
    self.cancelled = true
    self.ewent = nil
    self.listener_function = nil -- Clear the reference to the listener function to aid garbage collection
  end
end

---Suspend this EwentHandler. It is removed from the target event and will not receive events, but can be resumed later.
function EwentHandler:suspend()
  self:setSuspended(true)
end

---Resume this EwentHandler if it was previously suspended.
function EwentHandler:resume()
  self:setSuspended(false)
end

---Set the suspended state of this EwentHandler.
---@param suspended boolean Whether this EwentHandler should be suspended
function EwentHandler:setSuspended(suspended)
  if self.cancelled then return end

  if suspended ~= self.suspended then
    self.suspended = suspended

    if suspended then
      self.ewent:removeHandler(self)
    else
      self.ewent:addHandler(self)
    end
  end
end

return EwentHandler
