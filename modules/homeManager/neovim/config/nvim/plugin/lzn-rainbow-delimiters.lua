vim.g.rainbow_delimiters = {
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
}
