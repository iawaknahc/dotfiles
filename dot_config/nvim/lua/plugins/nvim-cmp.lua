function config()
  local cmp = require("cmp")

  local source_buffer = {
    name = "buffer",
    option = {
      keyword_pattern = [[\k\+]],
      -- complete from all buffers.
      get_bufnrs = function()
        return vim.api.nvim_list_bufs()
      end,
    },
  }
  local source_tmux = {
    name = "tmux",
    option = {
      all_panes = true,
    },
  }
  local source_path = { name = "path" }
  local source_cmdline_history = { name = "cmdline_history" }

  local mapping_cmdline = cmp.mapping.preset.cmdline()
  mapping_cmdline["<C-J>"] = mapping_cmdline["<C-N>"]
  mapping_cmdline["<C-K>"] = mapping_cmdline["<C-P>"]

  cmp.setup.cmdline({ "/", "?" }, {
    mapping = mapping_cmdline,
    sources = {
      source_buffer,
      source_tmux,
      source_cmdline_history,
      { name = "nvim_lsp_document_symbol" },
    },
  })

  cmp.setup.cmdline(":", {
    mapping = mapping_cmdline,
    sources = {
      source_buffer,
      source_tmux,
      source_path,
      { name = "cmdline" },
      source_cmdline_history,
    },
  })

  local make_jump = function(direction)
    return function(fallback)
      local luasnip = require("luasnip")
      -- locally_jumpable() means the cursor is now inside a snippet
      -- region and is jumpable.
      -- jumpable() ignores the current position of the cursor.
      -- If we use jumpable(), then pressing tab will jump back to the snippet,
      -- causing unwanted cursor movement.
      if luasnip.locally_jumpable(direction) then
        luasnip.jump(direction)
      else
        fallback()
      end
    end
  end
  local tab = make_jump(1)
  local s_tab = make_jump(-1)

  local mapping_insert = cmp.mapping.preset.insert()
  mapping_insert["<CR>"] = mapping_insert["<C-Y>"]
  mapping_insert["<C-J>"] = mapping_insert["<C-N>"]
  mapping_insert["<C-K>"] = mapping_insert["<C-P>"]
  mapping_insert["<Tab>"] = {
    i = tab,
    s = tab,
  }
  mapping_insert["<S-Tab>"] = {
    i = s_tab,
    s = s_tab,
  }

  cmp.setup({
    preselect = cmp.PreselectMode.None,
    -- nvim-cmp itself does not require a snippet engine to run.
    -- But some LSP servers like CSS only return snippet items.
    -- Therefore a snippet engine is required.
    -- See https://github.com/hrsh7th/nvim-cmp/issues/373#issuecomment-947359057
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = mapping_insert,
    sources = {
      source_buffer,
      source_tmux,
      source_path,
      { name = "nvim_lsp" },
      { name = "nvim_lua" },
      { name = "nvim_lsp_signature_help" },
    },
  })
end

return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "L3MON4D3/LuaSnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "dmitmel/cmp-cmdline-history",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lsp-document-symbol",
    "andersevenrud/cmp-tmux",
  },
  config = config,
}
