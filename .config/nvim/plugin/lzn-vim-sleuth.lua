require("lz.n").load({
  "vim-sleuth",
  -- :help sleuth says it does its job on the following events:
  -- BufNewFile
  -- BufReadPost
  -- BufFilePost
  --
  -- We need to make sure it loads before these events fire.
  event = { "BufNewFile", "BufReadPost", "BufFilePost" },
  before = function()
    -- Prevent this plugin to turn on filetype indentation.
    -- https://github.com/tpope/vim-sleuth/commit/e362d3552ba2fcf0bc1830a1c59e869b1c6f2067
    vim.g.sleuth_no_filetype_indent_on = 1
  end,
})
