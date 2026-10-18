local util = {}

---Creates a lazily evaluated value. The function `f` will only be called once, the first time the returned function is invoked.
---@generic T
---@param f fun(): T
---@return fun(): T
function util.lazy(f)
  local evaluated = false
  local result

  return function()
    if not evaluated then
      result = f()
      evaluated = true
    end
    return result
  end
end

return util
