require("lz.n").load({
  "vim-sleuth",
  event = {
    -- :help sleuth says it does its job on the following events.
    -- So lazy-load it on those events.
    -- Previously, it was loaded on VeryLazy, which was too late.
    "BufNewFile",
    "BufReadPost",
    "BufFilePost",
  },
  before = function()
    -- Prevent this plugin to turn on filetype indentation.
    -- https://github.com/tpope/vim-sleuth/blob/v1.2/plugin/sleuth.vim#L181
    vim.g.did_indent_on = true
  end,
})
