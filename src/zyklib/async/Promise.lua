---@alias zyklib.async.PromiseState "pending" | "fulfilled" | "rejected"

---@class zyklib.async.Promise<T>
---@field private state zyklib.async.PromiseState
---@field private value T?
---@field private reason any
---@field private callbacks fun(ok: boolean, value: any)[]
local promise = {}
promise.__index = promise

--- Create a new pending promise
--- @generic T
--- @return zyklib.async.Promise<T>
function promise.new()
  return setmetatable({
    state = "pending",
    callbacks = {},
  }, promise)
end

---Settles this promise
---@generic T
---@param self zyklib.async.Promise<T>
---@param state "fulfilled" | "rejected"
---@param value T # The resolved value or the rejection reason
function promise:_settle(state, value)
  if self.state ~= "pending" then return end

  self.state = state

  if state == "fulfilled" then
    self.value = value
  else
    self.reason = value
  end

  local callbacks = self.callbacks
  self.callbacks = {} -- Clear callbacks to aid garbage collection since they are no longer needed

  for _, callback in ipairs(callbacks) do
    callback(state == "fulfilled", value)
  end
end

---@param value T # The value to resolve the promise with
function promise:resolve(value)
  self:_settle("fulfilled", value)
end

---@param reason any # The reason to reject the promise with
function promise:reject(reason)
  self:_settle("rejected", reason)
end

---@param callback fun(value: T)
---@return self
function promise:onSuccess(callback)
  return self:onCompletion(function(ok, value)
    if ok then callback(value) end
  end)
end

---@param callback fun(reason: any)
---@return self
function promise:onFailure(callback)
  return self:onCompletion(function(ok, value)
    if not ok then callback(value) end
  end)
end

---@param callback fun(ok: boolean, value: any)
---@return self
function promise:onCompletion(callback)
  if self.state == "pending" then
    table.insert(self.callbacks, callback)
  else
    callback(self.state == "fulfilled",
      self.state == "fulfilled" and self.value or self.reason)
  end

  return self
end

---@generic U
---@param f fun(value: T): U
---@return zyklib.async.Promise<U>
function promise:map(f)
  local result = promise.new()

  self:onCompletion(function(ok, value)
    if not ok then
      result:reject(value)
      return
    end

    local success, mapped = pcall(f, value)

    if success then
      result:resolve(mapped)
    else
      result:reject(mapped)
    end
  end)

  return result
end

---@generic U
---@param f fun(value: T): zyklib.async.Promise<U>
---@return zyklib.async.Promise<U>
function promise:flatMap(f)
  local result = promise.new()

  self:onCompletion(function(ok, value)
    if not ok then
      result:reject(value)
      return
    end

    local success, nextPromise = pcall(f, value)

    if not success then
      result:reject(nextPromise)
      return
    end

    nextPromise:onCompletion(function(nextOk, nextValue)
      if nextOk then
        result:resolve(nextValue)
      else
        result:reject(nextValue)
      end
    end)
  end)

  return result
end

return promise
