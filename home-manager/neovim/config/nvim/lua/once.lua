---@generic T
---@param fn fun(...): T
---@return fun(...): T
local function once(fn)
  local called = false
  local result
  local ok
  return function(...)
    if not called then
      ok, result = pcall(fn, ...)
      if not ok then
        error(result)
        -- The function ends here
      else
        called = true
        -- fallthrough
      end
    end
    return result
  end
end

return once
