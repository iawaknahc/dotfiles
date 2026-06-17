require("catppuccin").setup({
  custom_highlights = function(colors)
    local U = require("catppuccin.utils.colors")
    return {
      -- According to the style guide,
      -- Changed lines or text should be in blue.
      -- See https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
      --
      -- The default is yellow, which is inconsistent with the rest of the theme.
      GitSignsChange = { fg = colors.blue },

      -- Use the opacity values suggested in the style guide.
      -- In particular, for lines (i.e. the background), we use the lowest suggested value of 0.10, and
      -- for changed text, which appears on changed lines, we use the highest suggested value of 0.25.
      -- So changed text is distinguishable from its background (i.e. changed lines).
      -- See https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md
      DiffAdd = { bg = U.blend(colors.green, colors.base, 0.10) }, -- Added lines
      DiffDelete = { bg = U.blend(colors.red, colors.base, 0.10) }, -- Deleted lines
      DiffChange = { bg = U.blend(colors.blue, colors.base, 0.10) }, -- Changed lines
      DiffText = { bg = U.blend(colors.blue, colors.base, 0.25) }, -- Changed text in changed lines
      DiffTextAdd = { bg = U.blend(colors.green, colors.base, 0.25) }, -- Added text in changed lines
    }
  end,
})

vim.cmd([[colorscheme catppuccin-mocha]])
