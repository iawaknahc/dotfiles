return {
  {
    -- Previously I used gitsigns.nvim
    -- But it does more than showing signs.
    "airblade/vim-gitgutter",
    enabled = true,
    event = {
      "VeryLazy",
    },
    init = function()
      -- Prevent it from setting up any keymappings for me.
      -- See https://github.com/airblade/vim-gitgutter#:~:text=if%20you%20don't%20want%20vim-gitgutter%20to%20set%20up%20any%20mappings%20at%20all
      vim.g.gitgutter_map_keys = 0
    end,
  },
}
