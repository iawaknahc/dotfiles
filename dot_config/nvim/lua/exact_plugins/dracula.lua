return {
  {
    "dracula/vim",
    name = "dracula",
    lazy = false,
    config = function()
      vim.cmd [[colorscheme dracula]]
      -- Make inlay hint less visually prominent.
      vim.cmd [[highlight DraculaInlayHint cterm=italic gui=italic ctermbg=NONE guibg=NONE]]
    end,
  },
}
