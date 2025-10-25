require("lz.n").load({
  "mini.ai",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    local ai = require("mini.ai")
    ai.setup({
      mappings = {
        around = "a",
        inside = "i",

        around_next = "",
        inside_next = "",
        around_last = "",
        inside_last = "",

        goto_left = "g[",
        goto_right = "g]",
      },
      -- The list of native text objects can be found at :h text-objects.
      -- They are
      -- w: word
      -- W: WORD
      -- s: sentence :h ) :h (
      -- p: paragraph :h } :h {
      -- []: []
      -- (): ()
      -- b: alias of ()
      -- <>: <>
      -- t: XML tag
      -- {}: {}
      -- B: alias of {}
      -- ": "
      -- ': '
      -- `: `
      --
      -- The list of builtin text objects by mini.ai can be found at :h MiniAi-textobject-builtin
      -- (): ()
      -- []: []
      -- {}: {}
      -- <>: <>
      -- b: alias for ) ] }
      -- ": "
      -- ': '
      -- `: `
      -- q: alias for " ' `
      -- t: XML tag
      -- f: function call
      -- a: argument
      -- ?: input interactively
      custom_textobjects = {
        f = false,

        -- a stands for argument.
        -- We cannot name this p because p is already taken, :h ip, :h ap
        a = ai.gen_spec.treesitter({
          a = "@parameter.outer",
          i = "@parameter.inner",
        }),

        -- The name is inspired by :h ]m, :h [m
        -- which stands for method.
        m = ai.gen_spec.treesitter({
          a = "@function.outer",
          i = "@function.inner",
        }),
      },
    })
  end,
})
