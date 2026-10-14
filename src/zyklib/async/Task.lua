---@alias zyklib.async.TaskState "pending" | "running" | "finished" | "cancelled" | "cancelrequested" | "error"

---@class zyklib.async.Task<T> : zyklib.disposable.IDisposable
---@field package result_promise zyklib.async.Promise<T>
---@field package coroutine thread
---@field package state zyklib.async.TaskState
---@field package result T
---@field package error any
---@field package tick_handler zyklib.reactive.EventHandler
local task = {}
task.__index = task

---@type table<thread, zyklib.async.Task>
local tasks = setmetatable({}, { __mode = "k" })

---@generic T Result type of the created task
---@param f fun():T
---@return zyklib.async.Task<T> # A new task that is not started yet.
function task.new(f)
  local zyklib = require("zyklib")

  local self = setmetatable({}, task)
  self.state = "pending"
  self.result_promise = zyklib.async.Promise.new()

  self.coroutine = coroutine.create(function()
    self.state = "running"

    local ok, result = pcall(f)

    if ok then
      self.state = "finished"
      self.result = result
    else
      self.state = "error"
      self.error = result
    end
  end)

  tasks[self.coroutine] = self

  self.tick_handler = zyklib.game_events.native.Logic:subscribeSuspended(function()
    if self.state == "running" then
      coroutine.resume(self.coroutine)

      if self.state == "cancelrequested" then
        -- Change the state from cancel requested to cancelled, so that it will now be properly cleaned up
        self.state = "cancelled"
      end
    end

    -- Clean up the task if it has finished, been cancelled, or encountered an error.
    if self.state == "finished"
        or self.state == "cancelled"
        or self.state == "error" then
      coroutine.close(self.coroutine)
      tasks[self.coroutine] = nil
      self.tick_handler:cancel()
    end

    -- Resolve the promise if the task has finished in this tick
    if self.state == "finished" then
      self.result_promise:resolve(self.result)
    elseif self.state == "error" then
      self.result_promise:reject(self.error)
    end
  end)


  return self
end

---Get a promise that resolves when this task finishes.
---@generic T
---@param self zyklib.async.Task<T>
---@return zyklib.async.Promise<T>
function task:asPromise()
  return self.result_promise
end

---Start this task. It won't execute right away, but it will be scheduled to run in the next game logic tick.
---@return zyklib.async.Task
function task:start()
  if self.state ~= "pending" then
    error("Cannot start a task that is not pending. Current state: " .. tostring(self.state))
  end

  self.state = "running"
  self.tick_handler:setActive(true)

  return self
end

--- Cancel this task. If the task is currently running, it will be marked as cancel requested and yield. If it's not running, it will be immediately cancelled.
function task:cancel()
  if self.state == "finished"
      or self.state == "cancelled"
      or self.state == "cancelrequested"
      or self.state == "error" then
    return
  end

  if coroutine.running() == self.coroutine then
    self.state = "cancelrequested"
    coroutine.yield()
  else
    coroutine.close(self.coroutine)
    self.state = "cancelled"

    tasks[self.coroutine] = nil
    self.tick_handler:cancel()
  end
end

---Gets the state of this task.
---@return zyklib.async.TaskState
function task:getState()
  return self.state
end

function task:dispose()
  self:cancel()
end

---Yields the currently active task if there is one. This is the only way to cooperatively yield a task.
function task.maybeYield()
  if tasks[coroutine.running()] then
    -- TODO: Once we have better timing, this needs to respect the interval setup. Currently, it always yields due to a lack of better measurement.
    coroutine.yield()
  end
end

return task
