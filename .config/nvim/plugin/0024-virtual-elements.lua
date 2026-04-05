-- Show or hide any virtual elements that could cause layout shift, including
-- 1. diagnostic virtual lines
-- 2. LSP codelens, as they are shown as virtual lines above the item as of 0.12
-- 3. LSP inlay hints, as they are shown as virtual text before the item.

vim.keymap.set({ "n" }, "<Leader>v", function()
  -- For simplicity, we use vim.lsp.inlay_hint.is_enabled as the source of truth.
  local enabled = vim.lsp.inlay_hint.is_enabled({
    bufnr = 0,
  })
  vim.lsp.inlay_hint.enable(not enabled, {
    bufnr = 0,
  })
  vim.lsp.codelens.enable(not enabled, {
    bufnr = 0,
  })
  if enabled then
    local config = vim.diagnostic.config()
    config = vim.tbl_deep_extend("force", config, {
      virtual_lines = false,
    })
    vim.diagnostic.config(config)
  else
    local config = vim.diagnostic.config()
    config = vim.tbl_deep_extend("force", config, {
      virtual_lines = {},
    })
    vim.diagnostic.config(config)
  end
end, {
  desc = "Toggle virtual lines",
})
