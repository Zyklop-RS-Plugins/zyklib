local Highlight = require "zyklib/highlights/Highlight"

---@class zyklib.HighlightGroup : zyklib.Highlight
---@field highlights zyklib.Highlight[]
local HighlightGroup = setmetatable({}, { __index = Highlight })
HighlightGroup.__index = HighlightGroup

---Creates a new HighlightGroup
---@param children zyklib.Highlight[] List of child highlights
---@return zyklib.HighlightGroup
function HighlightGroup.new(children)
  local self = setmetatable({}, HighlightGroup)
  self:init()
  self.highlights = children

  -- Set this group as the parent of all child highlights
  for _, value in pairs(children) do
    value.parent = self
  end

  return self
end

function HighlightGroup:activate()
  for _, value in ipairs(self.highlights) do
    value:activate()
  end
  return self
end

function HighlightGroup:deactivate()
  for _, value in ipairs(self.highlights) do
    value:deactivate()
  end
  return self
end

function HighlightGroup:propagate_param_change()
  Highlight.propagate_param_change(self) -- super call
  for _, value in ipairs(self.highlights) do
    value:propagate_param_change()
  end
end

return HighlightGroup
