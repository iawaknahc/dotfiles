local mytreesitter_autocmdgroup = vim.api.nvim_create_augroup("MyTreesitter", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = mytreesitter_autocmdgroup,
  pattern = "*",
  callback = function(ev)
    -- Legacy syntax is turned on by default (:h nvim-defaults).
    -- Legacy syntax is still useful when I do not install a treesitter parser for a given filetype, like man.
    -- If we run :scriptnames, we see synload.vim is still sourced.
    -- This is probably due to this trick.
    -- https://github.com/neovim/neovim/blob/v0.10.1/runtime/lua/vim/treesitter/highlighter.lua#L138
    --
    -- Some filetype has vim.treesitter.start() called by default.
    -- So we have to call stop()
    -- https://github.com/neovim/neovim/blob/v0.12.0/runtime/ftplugin/lua.lua#L2
    -- https://github.com/neovim/neovim/blob/v0.12.0/runtime/ftplugin/markdown.lua#L1
    -- https://github.com/neovim/neovim/blob/v0.12.0/runtime/ftplugin/query.lua#L11
    -- https://github.com/neovim/neovim/blob/v0.12.0/runtime/ftplugin/help.lua#L2
    --
    -- So at this point, it is :syntax on AND vim.treesitter.start() may have been called.
    -- To reverse, we have to call vim.treesitter.stop()
    -- When we later on detect that we do not want syntax highlight, we have to run :syntax off.
    vim.treesitter.stop(ev.buf)

    local filetype = ev.match

    -- Handle large number of lines
    local max_filesize = 1 * 1024 * 1024 -- 1MiB
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats ~= nil and stats.size > max_filesize then
      vim.bo[ev.buf].syntax = "OFF"
      return
    end

    -- Handle long lines
    -- It is safe to loop all lines because we have handled large number of lines above.
    local long_line = 1000
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      if #line > long_line then
        vim.bo[ev.buf].syntax = "OFF"
        return
      end
    end

    -- Try twice.
    -- Some special buffer like :h checkhealth only work with vim.treesitter.start(buf)
    local ok_with_ft, _err_with_ft = pcall(vim.treesitter.start, ev.buf, filetype)
    if not ok_with_ft then
      local _ok_without_ft, _err_without_ft = pcall(vim.treesitter.start, ev.buf)
    end
  end,
})
