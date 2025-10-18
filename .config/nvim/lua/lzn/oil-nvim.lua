vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("lz.n").load({
  "oil.nvim",
  enabled = vim.g.pager_enabled ~= 1,
  lazy = false,
  after = function()
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil: open directory" })

    require("oil").setup({
      -- Let Oil to take over the job of netrw.
      default_file_explorer = true,
      -- Make Oil buffers look like `ls -l`.
      -- Oil does not support owner and group yet.
      -- See https://github.com/stevearc/oil.nvim/issues/436
      columns = {
        "type",
        "permissions",
        "size",
        { "mtime", format = "%Y-%m-%d %H:%M:%S %z" },
      },
      buf_options = {
        -- Make Oil buffers listed, like normal buffers.
        buflisted = true,
        -- Make Oil buffers follow vim.o.hidden
        bufhidden = "",
      },
      -- Never delete Oil buffers automatically.
      -- https://github.com/stevearc/oil.nvim/issues/201#issuecomment-1771146785
      cleanup_delay_ms = false,
      -- Allow me to move freely in Oil buffers.
      constrain_cursor = false,
      keymaps = {
        -- Do not close the Oil buffer when a file is opened.
        ["<CR>"] = { "actions.select", opts = { close = false } },
        ["<Space>d"] = { "actions.send_to_qflist", opts = { action = "r", only_matching_search = true } },
      },
    })
  end,
})
