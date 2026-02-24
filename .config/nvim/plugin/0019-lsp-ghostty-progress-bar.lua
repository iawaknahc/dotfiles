-- lsp.Client.Progress has only one field: token.
-- So it is not useful at all.
-- Since a buffer can have multiple clients attached to it,
-- and there is only one progress bar,
-- we want to show the progress bar as long as there is at least one client is loading.
-- We want to dismiss the progress bar when there is no client is loading.
--
-- We keep track of the state of the progress bar in the variable st,
-- and the progress of seen clients in progress_by_client_id.

local mylsp_ghostty_progress_bar = vim.api.nvim_create_augroup("MyLSPGhosttyProgressBar", { clear = true })

-- https://conemu.github.io/en/AnsiEscapeCodes.html#ConEmu_specific_OSC
---@type 0 | 3
local st = 0

---@type table<integer, lsp.ProgressParams>
local progress_by_client_id = {}

local stdout = vim.uv.new_tty(1, false)

-- FIXME: neovim 0.12 nvim_echo seems to support OSC 9;4
local function osc_9_4()
  if stdout == nil then
    return
  end

  if vim.env.TMUX ~= nil then
    stdout:write(string.format("\x1bPtmux;\x1b\x1b]9;4;%d\x07\x1b\\", st))
  else
    stdout:write(string.format("\x1b]9;4;%d\x07", st))
  end
end

local function check_progress()
  local some_client_loading = false
  for _, progress in pairs(progress_by_client_id) do
    if progress.value.kind == "begin" or progress.value.kind == "report" then
      some_client_loading = true
    end
  end

  if some_client_loading and st == 0 then
    st = 3
    osc_9_4()
  end
  if not some_client_loading and st == 3 then
    st = 0
    osc_9_4()
  end
end

vim.api.nvim_create_autocmd("LspProgress", {
  group = mylsp_ghostty_progress_bar,
  callback = function(ev)
    ---@type integer
    local client_id = ev.data.client_id
    ---@type lsp.ProgressParams
    local params = ev.data.params
    local value = params.value or {}

    if value.kind == "begin" or value.kind == "report" or value.kind == "end" then
      progress_by_client_id[client_id] = params
    end

    check_progress()
  end,
})
