local mylsp_ghostty_progress_bar = vim.api.nvim_create_augroup("MyLSPGhosttyProgressBar", { clear = true })

-- Taken from the example in :help LspProgress
vim.api.nvim_create_autocmd("LspProgress", {
  group = mylsp_ghostty_progress_bar,
  callback = function(ev)
    ---@type integer
    local client_id = ev.data.client_id
    ---@type lsp.ProgressParams
    local params = ev.data.params
    local value = params.value or {}

    -- Progress messages are not worth writing to :messages
    local history = false
    -- nvim_echo() does not support tmux passthrough sequence out-of-the-box, so the progress bar DOES NOT show when
    -- tmux is being used in Ghostty.
    vim.api.nvim_echo({ { value.message or "done" } }, history, {
      id = "lsp." .. tostring(client_id),
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})
