require("lz.n").load({
  "which-key.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("which-key").setup({
      preset = "helix",
      -- Do not specify filter so that mappings of VIM plugin is shown, e.g. vim-table-mode.
      -- Set expand to 10 to show nested mappings, e.g vim-table-mode.
      expand = 10,
      spec = {
        { "gra", desc = "Code action" },
        { "grn", desc = "Rename" },
        { "]d", desc = "Next diagnostic" },
        { "]D", desc = "Last diagnostic" },
        { "[d", desc = "Previous diagnostic" },
        { "[D", desc = "First diagnostic" },

        { "gr", group = "LSP" },
        { "gs", group = "Surround / Treesitter" },
        { "<Leader>t", group = "Table mode" },
      },
    })
  end,
})
