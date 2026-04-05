-- :help ftdetect
-- When a buffer is read, set filetype=bigfile if the file is considered as big.
--
-- This would make features that rely on correct filetype to break, and this is what we want.
-- For example, when reading a large XML file, we want filetype=bigfile, so that
-- 1. treesitter highlighting is disabled because vim.treesitter.start() uses filetype to get the parser.
-- 2. regex-based highlighting is disabled because there is no regex-based highlight for bigfile.
-- 3. LSP is disabled because there is no LSP server for bigfile.
-- 4. Other plugins that assume correct filetype no longer function.

local BIGFILE_FILESIZE = 1 * 1024 * 1024 -- 1MiB
local BIGFILE_LONG_LINE = 1000

vim.api.nvim_create_autocmd({ "BufRead" }, {
  pattern = "*",
  callback = function(ev)
    -- Handle large number of lines
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats ~= nil and stats.size > BIGFILE_FILESIZE then
      vim.bo[ev.buf].filetype = "bigfile"
    end

    -- Handle long lines
    -- It is safe to loop all lines because we have handled large number of lines above.
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
      if #line > BIGFILE_LONG_LINE then
        vim.bo[ev.buf].filetype = "bigfile"
      end
    end
  end,
})
