-- It is observed that there is a noticable delay if a large file is opened and treesitter is used to create fold.

local myfold_autocmdgroup = vim.api.nvim_create_augroup("MyFold", { clear = true })

vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  group = myfold_autocmdgroup,
  callback = function(ev)
    local winids = vim.api.nvim_list_wins()
    for _, winid in ipairs(winids) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local filetype = vim.bo[bufnr].filetype

      if bufnr == ev.buf then
        if filetype ~= "bigfile" then
          vim.wo[winid].foldmethod = "expr"
        else
          vim.wo[winid].foldmethod = "manual"
        end
      end
    end
  end,
})
