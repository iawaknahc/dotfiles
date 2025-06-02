require("lz.n").load({
  "diffview.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  -- Eagerly load it so that `nvim +DiffviewFileHistory` works as expected.
  lazy = false,
  after = function()
    require("diffview").setup({
      hooks = {
        diff_buf_read = function()
          -- For some reason, wrap is not set to nowrap.
          -- We fix that with this hook.
          vim.wo.wrap = false
        end,
      },
    })
  end,
})
