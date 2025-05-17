require("lz.n").load({
  "which-key.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("which-key").setup({
      preset = "helix",
      filter = function(mapping)
        return mapping.desc ~= nil and mapping.desc ~= ""
      end,
      spec = {
        { "gra", desc = "Code action" },
        { "grn", desc = "Rename" },
        { "]d", desc = "Next diagnostic" },
        { "]D", desc = "Last diagnostic" },
        { "[d", desc = "Previous diagnostic" },
        { "[D", desc = "First diagnostic" },

        { "gr", group = "LSP" },
        { "gs", group = "Surround / Treesitter" },
      },
    })
  end,
})
