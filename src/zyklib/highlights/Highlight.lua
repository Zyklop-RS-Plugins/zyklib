local HighlightParams = require "zyklib/highlights/HighlightParams"

---@class zyklib.Geometry
---@field shapeData ShapeData
---@field lineWidth number
---@field isBillboard boolean

---@class zyklib.Highlight
---@field parent zyklib.HighlightGroup?
---@field self_params zyklib.HighlightParams
---@field actual_params zyklib.HighlightParams
---@field activate fun(self: zyklib.Highlight): self
---@field deactivate fun(self: zyklib.Highlight): self
---@field set fun(self: zyklib.Highlight, param: zyklib.HighlightParams): self
local Highlight = {}
Highlight.__index = Highlight

function Highlight:init()
  self.self_params = HighlightParams.default()
  self.actual_params = HighlightParams.default()
end

---Update the highlight parameters by blending the parameters of the (optional) parent highlight group with the parameters of this highlight.
---@return nil
function Highlight:propagate_param_change()
  if self.parent ~= nil then
    self.actual_params = HighlightParams.blend(self.parent.actual_params, self.self_params)
  else
    self.actual_params = self.self_params
  end
end

---Hides the highlight without destroying its instance or geometry.
---@return self
function Highlight:hide()
  self.self_params.visible = false
  self:propagate_param_change()
  return self
end

---Shows a previously hidden highlight
---@return self
function Highlight:show()
  self.self_params.visible = true
  self:propagate_param_change()
  return self
end

function Highlight:setIgnoreDepth(ignoreDepth)
  self.self_params.ignoreDepth = ignoreDepth
  self:propagate_param_change()
  return self
end

---Sets the colour of the highlight.
---@param colour ColourRGBA
---@return zyklib.Highlight
function Highlight:setColour(colour)
  self.self_params.colour = colour
  self:propagate_param_change()
  return self
end

return Highlight
