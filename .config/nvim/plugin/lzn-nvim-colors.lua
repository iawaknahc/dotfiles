vim.g.nvim_colors = {
  ---@param ev vim.api.keyset.create_autocmd.callback_args
  ---@return boolean
  enabled = function(ev)
    return vim.bo[ev.buf].filetype ~= "bigfile"
  end,
}
