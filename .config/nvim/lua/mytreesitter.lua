local mytreesitter_autocmdgroup = vim.api.nvim_create_augroup("MyTreesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = mytreesitter_autocmdgroup,
  pattern = "*",
  callback = function(ev)
    local buf = ev.buf
    local filetype = ev.match

    local max_filesize = 100 * 1024 -- 100KiB
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stats ~= nil and stats.size > max_filesize then
      return
    end

    -- Try twice.
    -- Some special buffer like :h checkhealth only work with vim.treesitter.start(buf)
    local ok_with_ft, _err_with_ft = pcall(vim.treesitter.start, buf, filetype)
    if not ok_with_ft then
      local _ok_without_ft, _err_without_ft = pcall(vim.treesitter.start, buf)
    end
  end,
})
