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
      -- Start of general pickers
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
      -- g stands for grep.
      {
        "<Leader>g", function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Open live grep",
      },
      -- End of general pickers

      -- Start of LSP pickers
      -- Helix space mode usually opens pickers.
      -- Helix also has goto mode i to "go to implementation".
      -- Since here we are opening a picker, so this should be a space mode keymap.
      {
        "<Leader>i", function()
          require("telescope.builtin").lsp_implementations()
        end,
        desc = "Open implementations of the interface under the cursor",
      },
      -- r stands for references.
      -- When this is used on a function,
      -- the results are similar to listing incoming calls.
      {
        "<Leader>r", function()
          require("telescope.builtin").lsp_references()
        end,
        desc = "Open references to the symbol under the cursor",
      },
      -- c stands for incoming "c"alls.
      {
        "<Leader>c", function()
          require("telescope.builtin").lsp_incoming_calls()
        end,
        desc = "Open incoming calls to the function under the cursor",
      },
      -- C stands for outgoing "c"alls.
      -- It is C because outgoing calls are less common.
      {
        "<Leader>C", function()
          require("telescope.builtin").lsp_outgoing_calls()
        end,
        desc = "Open outgoing calls from the function under the cursor",
      },
      -- s stands for "s"ymbols.
      {
        "<Leader>s", function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "Open symbols in the current buffer",
      },
      -- S stands for "s"ymbols.
      -- It is S because it lists more results.
      -- There is also lsp_workspace_symbols but gopls does not give any results.
      {
        "<Leader>S", function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end,
        desc = "Open symbols in the workspace",
      },
      -- Diagnostics is preferred over loclist because it supports severity.
      --vim.keymap.set('n', '<Leader>l', function() require('telescope.builtin').loclist({ show_line = false }) end)
      -- Inspired by Helix space mode d
      {
        "<Leader>d", function()
          require("telescope.builtin").diagnostics({ bufnr = 0 })
        end,
        desc = "Open diagnostics of the current buffer",
      },
      {
        "<Leader>D", function()
          require("telescope.builtin").diagnostics({ bufnr = nil })
        end,
        desc = "Open diagnostics of all buffers",
      },
      -- End of LSP pickers
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = config,
  },
}
