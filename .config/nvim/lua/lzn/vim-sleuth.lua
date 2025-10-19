require("lz.n").load({
  "vim-sleuth",
  enabled = vim.g.pager_enabled ~= 1,
  -- :help sleuth says it does its job on the following events:
  -- BufNewFile
  -- BufReadPost
  -- BufFilePost
  --
  -- We need to make sure it loads before these events fire.
  event = { "BufNewFile", "BufReadPost", "BufFilePost" },
  before = function()
    -- Prevent this plugin to turn on filetype indentation.
    -- https://github.com/tpope/vim-sleuth/blob/v1.2/plugin/sleuth.vim#L181
    vim.g.did_indent_on = true
  end,
})
