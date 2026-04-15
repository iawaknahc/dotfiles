require("fzf-lua").setup({
  fzf_opts = {
    ["--layout"] = "default",
  },
  winopts = {
    -- Disallow fzf-lua to enable treesitter highlighting because it does not handle large files or long lines.
    treesitter = false,
    preview = {
      vertical = "up:50%",
      horizontal = "right:50%",
      delay = 10,
    },
  },
})

-- Use fzf-lua for vim.ui.select
require("fzf-lua").register_ui_select()

-- Keep only the keymaps that I actually use.
-- For others, Use <Space><Space> to run :FzfLua, and then type the name to invoke the picker fuzzily.
vim.keymap.set("n", "<Space><Space>", "<CMD>FzfLua<CR>", {
  desc = ":FzfLua",
})

-- Inspired by Helix space mode f
vim.keymap.set("n", "<Space>f", "<CMD>FzfLua global<CR>", {
  desc = ":FzfLua global",
})
vim.keymap.set("n", "<Space>F", "<CMD>FzfLua git_files<CR>", {
  desc = ":FzfLua git_files",
})

-- Inspired by Helix space mode b
vim.keymap.set("n", "<Space>b", "<CMD>FzfLua buffers<CR>", {
  desc = ":FzfLua buffers",
})

-- Inspired by Helix space mode D
vim.keymap.set("n", "<Space>D", "<CMD>FzfLua diagnostics_workspace<CR>", {
  desc = ":FzfLua diagnostics_workspace",
})

-- The picker version of :chistory
vim.keymap.set("n", "<Space>Q", "<CMD>FzfLua quickfix_stack<CR>", {
  desc = ":FzfLua quickfix_stack",
})

-- The picker version of :lhistory
vim.keymap.set("n", "<Space>L", "<CMD>FzfLua loclist_stack<CR>", {
  desc = ":FzfLua loclist_stack",
})

vim.keymap.set("n", "<Space>q", "<CMD>FzfLua quickfix<CR>", {
  desc = ":FzfLua quickfix",
})

vim.keymap.set("n", "<Space>l", "<CMD>FzfLua loclist<CR>", {
  desc = ":FzfLua loclist",
})

-- OPTION-c to open directory, just like the FZF shell integration.
-- We use the same keymap.
vim.keymap.set("n", "<M-c>", function()
  require("fzf-lua").files({
    fd_opts = "--type d",
    hidden = true,
    actions = {
      ["enter"] = function(selected_lines)
        local line = selected_lines[1]
        if line ~= nil then
          -- Use the recommended function to strip preceding icon.
          -- https://github.com/ibhagwan/fzf-lua/discussions/2608
          local entry = require("fzf-lua").path.entry_to_file(line)
          require("oil").open(entry.path)
        end
      end,
    },
  })
end, {
  desc = "Open directories",
})

vim.keymap.set("n", "<M-C>", function()
  local cwd = require("get_buffer_directory")(0)
  require("fzf-lua").files({
    cmd = "parents.sh",
    cwd = cwd,
    actions = {
      ["enter"] = function(selected_lines)
        local line = selected_lines[1]
        if line ~= nil then
          -- Use the recommended function to strip preceding icon.
          -- https://github.com/ibhagwan/fzf-lua/discussions/2608
          local entry = require("fzf-lua").path.entry_to_file(line)
          require("oil").open(entry.path)
        end
      end,
    },
  })
end, {
  desc = "Open parent directories",
})
