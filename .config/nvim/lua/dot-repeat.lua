local M = {}

-- This is a very simplified version of dot-repeat.
-- See https://www.vikasraj.dev/blog/vim-dot-repeat
-- See https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
--
-- We could have use nvim_feedkeys(, "nt") and use @: to repeat too,
-- but hitting @: to repeat is not as ergonomic as hitting .
-- We are aware that a operatorfunc should support both normal mode and visual mode, v:count, [ ] < >, etc.
-- But ergonomics is what matters here.
--- @param fn_name string
--- @param fn fun(): nil
--- @return fun(): nil
function M.make_repeatable(fn_name, fn)
  local global_fn_name = "operatorfunc_" .. fn_name
  _G[global_fn_name] = function(type_)
    if type_ == nil then
      vim.o.operatorfunc = "v:lua." .. global_fn_name
      -- l is just a placeholder motion to trigger g@ to execute once.
      return "g@l"
    end
    fn()
  end
  return _G[global_fn_name]
end

return M
