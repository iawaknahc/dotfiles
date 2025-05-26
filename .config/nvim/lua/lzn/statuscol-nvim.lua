require("lz.n").load({
  "statuscol.nvim",
  event = { "DeferredUIEnter" },
  after = function()
    local builtin = require("statuscol.builtin")
    require("statuscol").setup({
      segments = {
        -- builtin.foldfunc is different from %C that it never show the fold level.
        {
          text = { builtin.foldfunc },
          click = "v:lua.ScFa",
        },
        { text = { "%s" }, click = "v:lua.ScSa" },
        {
          text = { "%l", " " },
          condition = { true, builtin.not_empty },
          click = "v:lua.ScLa",
        },
      },
    })
  end,
})
