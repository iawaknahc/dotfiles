require("lz.n").load({
  "statuscol.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      segments = {
        -- builtin.foldfunc is different from %C that it never show the fold level.
        {
          text = { builtin.foldfunc, " " },
          condition = { true, builtin.not_empty },
          click = "v:lua.ScFa",
        },

        -- We use the capability of statuscol.nvim to place the signs.
        -- This override the builtin behavior of nvim that uses priority to place the signs from left to right.
        {
          sign = {
            name = { "Dap.*" },
          },
          click = "v:lua.ScSa",
        },
        {
          sign = {
            namespace = { "diagnostic.*" },
          },
          click = "v:lua.ScSa",
        },

        {
          text = { "%l", " " },
          condition = { true, builtin.not_empty },
          click = "v:lua.ScLa",
        },

        -- Show gitsigns to the right of the line number, like in vscode.
        {
          sign = {
            namespace = { "gitsigns.*" },
            wrap = true,
          },
          click = "v:lua.ScSa",
        },
      },
    })
  end,
})
