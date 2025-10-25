require("lz.n").load({
  "rainbow-delimiters.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  -- This plugin listens FileType.
  -- See https://github.com/HiPhish/rainbow-delimiters.nvim/blob/v0.10.0/plugin/rainbow-delimiters.lua#L51
  event = { "FileType" },
  after = function()
    require("rainbow-delimiters.setup").setup({
      strategy = {
        [""] = "rainbow-delimiters.strategy.global",
      },
      query = {
        [""] = "rainbow-delimiters",
      },
      priority = {
        -- As of neovim 0.11.4, the largest value in vim.hl.priorities is 200.
        -- So 210 is enough to be the highest priority.
        [""] = 210,
      },
    })
  end,
})
