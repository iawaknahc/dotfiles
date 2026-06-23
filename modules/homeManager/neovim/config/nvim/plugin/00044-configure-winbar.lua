local lib_statusline = require("lib_statusline")

function WINBAR_WINBAR()
  local winid = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local filename = lib_statusline.filename(winid)
  local colon = "%#NonText#:%*"
  return "w" .. tostring(winid) .. colon .. "b" .. tostring(bufnr) .. colon .. "%<" .. filename
end

-- Set winbar to filename.
-- Filename also appears in the statusline, but when horizontal split is in use, it is truncated.
-- So we reserve the winbar to show filename.
vim.o.winbar = "%{%v:lua.WINBAR_WINBAR()%}"
