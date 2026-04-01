-- Inspired by gd
vim.keymap.set({ "n" }, "gD", function()
  vim.lsp.buf.declaration()
end, {
  desc = "Go to declaration",
})

-- After trying inlay hint for some time,
-- I found it quite annoying.
-- So do not enable it initially.
vim.keymap.set({ "n" }, "grh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
    bufnr = 0,
  }), {
    bufnr = 0,
  })
end, {
  desc = "Toggle inlay hints",
})

-- I am aware that this keymap is builtin, but
-- we want to set anchor_bias to above because
-- it clashes with the dropdown of blink.cmp very often.
vim.keymap.set("i", "<C-s>", function()
  vim.lsp.buf.signature_help({
    focusable = false,
    anchor_bias = "above",
    max_height = 30,
    max_width = 80,
  })
end, {
  desc = "vim.lsp.buf.signature_help()",
})

local mylsp_autocmdgroup = vim.api.nvim_create_augroup("MyLSP", { clear = true })

-- Disable inlay hint when entering insert mode.
vim.api.nvim_create_autocmd("InsertEnter", {
  group = mylsp_autocmdgroup,
  callback = function(args)
    local bufnr = args.buf

    vim.b.inlay_hint_is_enabled = vim.lsp.inlay_hint.is_enabled({
      bufnr = bufnr,
    })

    vim.lsp.inlay_hint.enable(false, {
      bufnr = bufnr,
    })
  end,
})

-- Restore inlay hint when leaving insert mode.
vim.api.nvim_create_autocmd("InsertLeave", {
  group = mylsp_autocmdgroup,
  callback = function(args)
    local bufnr = args.buf

    local is_enabled = vim.b.inlay_hint_is_enabled
    if is_enabled ~= nil then
      vim.lsp.inlay_hint.enable(is_enabled, {
        bufnr = bufnr,
      })
    end
  end,
})
