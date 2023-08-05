function config()
  local actions = require('telescope.actions')
  local builtin = require('telescope.builtin')

  require('telescope').setup {
    defaults = {
      vimgrep_arguments = {
        'rg',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--ignore',
        '--hidden',
        '--color=never',
        -- Explicitly ignore .git because it is a hidden file that is not in .gitignore.
        -- https://github.com/BurntSushi/ripgrep/issues/1509#issuecomment-595942433
        '--glob=!.git/',
      },
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
        },
      },
    },
  }

  local project_files = function()
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

  vim.keymap.set('n', '<Leader>f', project_files)
  vim.keymap.set('n', '<Leader>b', builtin.buffers)
  vim.keymap.set('n', '<Leader>g', builtin.live_grep)
  vim.keymap.set('n', 'gi', builtin.lsp_implementations)
  -- Diagnostics is preferred over loclist because it supports severity.
  --vim.keymap.set('n', '<Leader>l', function() require('telescope.builtin').loclist({ show_line = false }) end)
  -- Turns out I actually did not use this.
  --vim.keymap.set('n', '<Leader>l', function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end)
end

return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = config,
  }
}
