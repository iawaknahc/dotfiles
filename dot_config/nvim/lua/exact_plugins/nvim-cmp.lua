local function config()
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
      -- The order implies priority.
      { name = "nvim_lsp_document_symbol" },
      source_buffer,
      source_tmux,
      source_cmdline_history,
    },
  })

  cmp.setup.cmdline(":", {
    mapping = mapping_cmdline,
    sources = {
      -- The order implies priority.
      { name = "cmdline" },
      source_cmdline_history,
      source_buffer,
      source_tmux,
      source_path,
    },
  })

  local make_jump = function(direction)
    return function(fallback)
      if vim.snippet.active({ direction = direction }) then
        vim.snippet.jump(direction)
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
    -- As of nvim 0.10, it provides a native snippet engine.
    snippet = {
      expand = function(args)
        vim.snippet.expand(args.body)
      end,
    },
    mapping = mapping_insert,
    sources = {
      { name = "nvim_lsp_signature_help" },
      { name = "nvim_lsp" },
      { name = "nvim_lua" },
      source_buffer,
      source_tmux,
      source_path,
    },
  })
end

return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
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
