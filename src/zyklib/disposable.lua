--- Objects implementing this interface represent resources that can be disposed of.
--- @class zyklib.disposable.IDisposable
--- @field dispose fun(self: zyklib.disposable.IDisposable) Disposes of the resources held by this disposable. Should be idempotent, i.e. repeated invocations have no additional effect.

---!doctype module
---@class zyklib.disposable
local disposable = {}

--- @class zyklib.disposable.DisposableGroup: zyklib.disposable.IDisposable
--- @field disposables zyklib.disposable.IDisposable[] The list of disposables managed by this group.
disposable.DisposableGroup = {}
disposable.DisposableGroup.__index = disposable.DisposableGroup

--- Construct a new disposable Group that wraps multiple disposables into a single group.
--- @return zyklib.disposable.DisposableGroup
function disposable.DisposableGroup.new()
  local self = setmetatable({}, disposable.DisposableGroup)
  self.disposables = {}
  return self
end

---Disposes every element of this disposable group.
function disposable.DisposableGroup:dispose()
  for _, disposable in ipairs(self.disposables or {}) do
    disposable:dispose()
  end
end

--- Adds a new disposable to this disposable group.
---@param element zyklib.disposable.IDisposable
function disposable.DisposableGroup:add(element)
  self.disposables = self.disposables or {}
  table.insert(self.disposables, element)
end

--- Wraps any parameterless function as a disposable. Use this to wrap
--- @param func fun() The function to be called when disposing.
--- @return zyklib.disposable.IDisposable
function disposable.wrap(func)
  return {
    dispose = func
  }
end

return disposable
