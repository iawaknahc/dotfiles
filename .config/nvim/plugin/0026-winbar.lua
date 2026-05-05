local lib_statusline = require("lib_statusline")

function WINBAR_WINBAR()
  return lib_statusline.filename(vim.api.nvim_get_current_win())
end

-- Set winbar to filename.
-- Filename also appears in the statusline, but when horizontal split is in use, it is truncated.
-- So we reserve the winbar to show filename.
vim.o.winbar = "%{%v:lua.WINBAR_WINBAR()%}"
