---@class zyklib.UniqueNameGenerator
---@field prefix string
---@field predicate fun(name: string): boolean
---@field private counter integer
local UniqueNameGenerator = {}
UniqueNameGenerator.__index = UniqueNameGenerator


function UniqueNameGenerator.new(prefix, predicate)
  predicate = predicate or function(name) return true end

  local self = setmetatable({}, UniqueNameGenerator)
  self.prefix = prefix
  self.predicate = predicate
  self.counter = 0

  return self
end

function UniqueNameGenerator:next()
  while true do
    local name = self.prefix .. self.counter
    self.counter = self.counter + 1
    if self.predicate(name) then
      return name
    end
  end
end

return UniqueNameGenerator