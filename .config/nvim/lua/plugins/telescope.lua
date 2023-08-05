function config()
  local actions = require('telescope.actions')
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

  -- registers() is require("telescope.builtin").registers()
  -- except that only nonempty registers are shown.
  local registers = function()
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local make_entry = require("telescope.make_entry")
    local sorters = require("telescope.sorters")
    local actions = require("telescope.actions")
    local opts = {}

    local all_registers = { '"', "_", "#", "=", "_", "/", "*", "+", ":", ".", "%" }
    for i = 0, 9 do
      table.insert(all_registers, tostring(i))
    end
    for i = 65, 90 do
      table.insert(all_registers, string.char(i))
    end

    local nonempty_registers = {}
    for i, v in ipairs(all_registers) do
      if vim.trim(vim.fn.getreg(v)) ~= "" then
        table.insert(nonempty_registers, v)
      end
    end

    pickers.new(opts, {
      prompt_title = "Registers",
      finder = finders.new_table {
        results = nonempty_registers,
        entry_maker = make_entry.gen_from_registers(opts),
      },
      sorter = sorters.get_levenshtein_sorter(),
      attach_mappings = function(_, map)
        actions.select_default:replace(actions.paste_register)
        map("i", "<C-e>", actions.edit_register)
        return true
      end,
    }):find()
  end

  vim.keymap.set('n', '<Leader>f', project_files)
  vim.keymap.set('n', '<Leader>r', registers)
  vim.keymap.set('n', '<Leader>b', function() require('telescope.builtin').buffers() end)
  vim.keymap.set('n', '<Leader>g', function() require('telescope.builtin').live_grep() end)
  -- Diagnostics is preferred over loclist because it supports severity.
  --vim.keymap.set('n', '<Leader>l', function() require('telescope.builtin').loclist({ show_line = false }) end)
  vim.keymap.set('n', '<Leader>l', function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end)
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
