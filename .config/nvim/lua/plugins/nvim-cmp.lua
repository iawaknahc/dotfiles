function config()
  local cmp = require("cmp")

  local source_buffer = {
    name = "buffer",
    option = {
      keyword_pattern = [[\k\+]],
    },
  }
  local source_path = { name = "path" }
  local source_cmdline_history = { name = "cmdline_history" }

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

  local mapping_cmdline = cmp.mapping.preset.cmdline({
    ["<Tab>"] = {
      c = tab_completion,
    },
  })
  mapping_cmdline["<C-J>"] = mapping_cmdline["<C-N>"]
  mapping_cmdline["<C-K>"] = mapping_cmdline["<C-P>"]

  cmp.setup.cmdline({ "/", "?" }, {
    mapping = mapping_cmdline,
    sources = {
      source_buffer,
      source_cmdline_history,
      { name = "nvim_lsp_document_symbol" },
    },
  })

  cmp.setup.cmdline(":", {
    mapping = mapping_cmdline,
    sources = {
      source_buffer,
      source_path,
      { name = "cmdline" },
      source_cmdline_history,
    },
  })

  local mapping_insert = cmp.mapping.preset.insert({
    ["<CR>"] = {
      i = enter_completion,
    },
  })
  mapping_insert["<C-J>"] = mapping_insert["<C-N>"]
  mapping_insert["<C-K>"] = mapping_insert["<C-P>"]

  cmp.setup({
    preselect = cmp.PreselectMode.None,
    -- nvim-cmp itself does not require a snippet engine to run.
    -- But some LSP servers like CSS only return snippet items.
    -- Therefore a snippet engine is required.
    -- See https://github.com/hrsh7th/nvim-cmp/issues/373#issuecomment-947359057
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = mapping_insert,
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
    "dmitmel/cmp-cmdline-history",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lsp-document-symbol",
  },
  config = config,
}
