return {
  {
    "tpope/vim-sleuth",
    init = function()
      -- Prevent this plugin to turn on filetype indentation.
      -- https://github.com/tpope/vim-sleuth/blob/v1.2/plugin/sleuth.vim#L181
      vim.g.did_indent_on = true
    end,
  },
}
