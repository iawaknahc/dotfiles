return {
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require('dap')
      local widgets = require('dap.ui.widgets')
      local map_opts = { noremap = true }
      vim.keymap.set('n', '<F5>', dap.continue, map_opts)
      vim.keymap.set('n', '<F10>', dap.step_over, map_opts)
      vim.keymap.set('n', '<F11>', dap.step_into, map_opts)
      vim.keymap.set('n', '<F12>', dap.step_out, map_opts)
      vim.keymap.set('n', '<Leader>R', dap.repl.toggle, map_opts)
      vim.keymap.set({'n','v'}, '<Leader>K', widgets.hover, map_opts)
    end,
  }
}
