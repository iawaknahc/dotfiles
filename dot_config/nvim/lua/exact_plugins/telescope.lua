local function project_files()
  local git_files = require("telescope.builtin").git_files
  local find_files = require("telescope.builtin").find_files
  local ok = pcall(git_files, {
    use_git_root = false,
  })
  if not ok then
    find_files({
      find_command = {
        "find",
        ".",
        "-type",
        "f",
        "-maxdepth",
        "2",
      },
    })
  end
end

local function config()
  local actions = require("telescope.actions")

  require("telescope").setup {
    defaults = {
      vimgrep_arguments = {
        "rg",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--ignore",
        "--hidden",
        "--color=never",
        -- Explicitly ignore .git because it is a hidden file that is not in .gitignore.
        -- https://github.com/BurntSushi/ripgrep/issues/1509#issuecomment-595942433
        "--glob=!.git/",
      },
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
      },
    },
  }
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = {
      "Telescope",
    },
    keys = {
      -- Inspired by Helix space mode f
      {
        "<Leader>f", project_files,
        desc = "Open project files"
      },
      -- Inspired by Helix space mode b
      {
        "<Leader>b", function()
          require("telescope.builtin").buffers()
        end,
        desc = "Open buffers",
      },
      {
        "<Leader>g", function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Live grep",
      },
      -- Inspired by Helix goto mode i
      {
        "gi", function()
          require("telescope.builtin").lsp_implementations()
        end,
        desc = "Open implementations",
      },
      -- Diagnostics is preferred over loclist because it supports severity.
      --vim.keymap.set('n', '<Leader>l', function() require('telescope.builtin').loclist({ show_line = false }) end)
      -- Inspired by Helix space mode d
      {
        "<Leader>d", function()
          require("telescope.builtin").diagnostics({ bufnr = 0 })
        end,
        desc = "Open diagnostics",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = config,
  },
}
