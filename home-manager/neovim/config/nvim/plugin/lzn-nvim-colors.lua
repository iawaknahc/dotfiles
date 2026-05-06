---@param ev vim.api.keyset.create_autocmd.callback_args
---@return boolean
vim.g.nvimcolors_enabled = function(ev)
  return vim.bo[ev.buf].filetype ~= "bigfile"
end
