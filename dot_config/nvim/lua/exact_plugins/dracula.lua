return {
  {
    "dracula/vim",
    -- rg "lazy = false" shows eagerly loaded plugins.
    lazy = false,
    name = "dracula",
    config = function()
      vim.cmd [[colorscheme dracula]]
      -- Make inlay hint less visually prominent.
      vim.cmd [[highlight DraculaInlayHint cterm=italic gui=italic ctermbg=NONE guibg=NONE]]
    end,
  },
}
