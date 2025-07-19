-- Inspired by gd
vim.keymap.set({ "n" }, "gD", vim.lsp.buf.declaration, {
  desc = "Go to declaration",
})

-- Inspired by Helix goto mode y
vim.keymap.set({ "n" }, "gy", vim.lsp.buf.type_definition, {
  desc = "Go to type definition",
})

-- Inspired by Helix space mode d
vim.keymap.set("n", "<Space>d", function()
  vim.diagnostic.setloclist()
end, {
  desc = ":lua vim.diagnostic.setloclist()",
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

-- Enhanced gx
vim.keymap.set({ "n" }, "gx", function()
  local function gx()
    local word = vim.fn.expand("<cfile>")
    vim.ui.open(word)
  end

  --- @return vim.lsp.Client|nil
  local function get_gopls()
    local clients = vim.lsp.get_clients({
      name = "gopls",
      method = "textDocument/documentLink",
    })
    if #clients == 0 then
      return nil
    end
    return clients[1]
  end

  --- @param document_link lsp.DocumentLink
  --- @return boolean
  local function is_package_documentation_link(document_link)
    local target = document_link.target
    if target == nil then
      return false
    end
    if vim.startswith(target, "https://pkg.go.dev/") then
      return true
    end
    return false
  end

  ---@param pos lsp.Position
  ---@param range lsp.Range
  ---@return boolean
  local function is_in_range(pos, range)
    if pos.line > range.start.line and pos.line < range["end"].line then
      return true
    elseif pos.line == range.start.line and pos.line == range["end"].line then
      return pos.character >= range.start.character and pos.character <= range["end"].character
    elseif pos.line == range.start.line then
      return pos.character >= range.start.character
    elseif pos.line == range["end"].line then
      return pos.character <= range["end"].character
    else
      return false
    end
  end

  local gopls = get_gopls()
  if gopls == nil then
    gx()
    return
  end

  gopls:request(
    "textDocument/documentLink",
    vim.lsp.util.make_position_params(0, "utf-8"),
    function(err, result, context, _config)
      if err == nil then
        --- @type lsp.Position
        local cursor_position = context.params.position

        for _, item in ipairs(result) do
          --- @type lsp.DocumentLink
          local document_link = item
          local range = document_link.range
          if is_package_documentation_link(document_link) then
            if is_in_range(cursor_position, range) then
              vim.ui.open(document_link.target)
              return
            end
          end
        end
      end

      gx()
    end
  )
end, {
  desc = "Open link under cursor",
})

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
