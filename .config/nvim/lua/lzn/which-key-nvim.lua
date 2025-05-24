require("lz.n").load({
  "which-key.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    require("which-key").setup({
      preset = "helix",

      filter = function(mapping)
        -- Do not show <Nop>.
        if mapping.rhs ~= nil and type(mapping.rhs) == "string" and mapping.rhs == "" then
          return false
        end
        return true
      end,

      expand = function(node)
        if node.mapping ~= nil and node.mapping.desc == "Table mode" then
          return true
        end
        return false
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
        { "<Leader>t", group = "Table mode" },
      },
    })
  end,
})
