local mytreesitter_autocmdgroup = vim.api.nvim_create_augroup("MyTreesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = mytreesitter_autocmdgroup,
  pattern = "*",
  callback = function(ev)
    -- Try twice.
    -- Some special buffer like :h checkhealth only work with vim.treesitter.start(buf)
    local ok_with_ft, _err_with_ft = pcall(vim.treesitter.start, ev.buf, ev.match)
    if not ok_with_ft then
      local _ok_without_ft, _err_without_ft = pcall(vim.treesitter.start, ev.buf)
    end
  end,
})
