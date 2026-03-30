local lazy = vim.g.fugitive_eager_load ~= 1
local event = nil
if lazy then
  event = { "DeferredUIEnter" }
end

require("lz.n").load({
  "vim-rhubarb",
  lazy = lazy,
  event = event,
})
