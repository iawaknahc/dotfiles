function config()
  local cmp = require("cmp")

  local source_buffer = {
    name = "buffer",
    option = {
      keyword_pattern = [[\k\+]],
    },
  }
  local source_path = { name = "path" }

  local tab_completion = function(fallback)
    if cmp.visible() and cmp.get_selected_entry() then
      cmp.confirm()
    elseif cmp.visible() then
      cmp.select_next_item()
    else
      fallback()
    end
  end

  local enter_completion = function(fallback)
    if cmp.visible() and cmp.get_selected_entry() then
      cmp.confirm()
    else
      fallback()
    end
  end

  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline({
      ["<Tab>"] = {
        c = tab_completion,
      },
    }),
    sources = {
      source_buffer,
      { name = "nvim_lsp_document_symbol" },
    },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline({
      ["<Tab>"] = {
        c = tab_completion,
      },
    }),
    sources = {
      source_buffer,
      source_path,
      { name = "cmdline" },
    },
  })

  cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<CR>"] = {
        i = enter_completion,
      },
    }),
    sources = {
      source_buffer,
      source_path,
      { name = "nvim_lsp" },
      { name = "vsnip" },
      { name = "nvim_lua" },
      { name = "nvim_lsp_signature_help" },
    },
  })
end

return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/vim-vsnip",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lsp-document-symbol",
  },
  config = config,
}
