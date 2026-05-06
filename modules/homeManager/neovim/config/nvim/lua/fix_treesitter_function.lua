-- Some treesitter plugins assume that parser:parse() has been called once.
-- This may not be true if I do not have another plugin doing that.
-- So we make this wrapper function to wrap any problematic plugin function.
--
---@generic F: function
---@param fn F
---@return F
local function fix_treesitter_function(fn)
  return function(...)
    local ok, parser = pcall(vim.treesitter.get_parser)
    if ok and parser ~= nil then
      parser:parse(true)
    end
    fn(...)
  end
end

return fix_treesitter_function
