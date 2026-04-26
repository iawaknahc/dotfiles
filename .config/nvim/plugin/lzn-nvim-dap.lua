local once = require("once")

local setup = once(function()
  require("dap-view").setup({
    winbar = {
      sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
      controls = {
        enabled = true,
      },
    },
    virtual_text = {
      enabled = true,
    },
  })

  require("dap-python").setup("debugpy-adapter")

  require("dap-go").setup({
    delve = {
      -- The workflow of debug a program is:
      -- 1. Replace `go run <PACKAGE>` with `dlv debug -l 127.0.0.1:38697 --headless --accept-multiclient`
      -- 2. In nvim, :lua require('dap').continue() and select the following configuration 'attach-remote-delve'
      -- 3. In nvim, set breakpoints with statuscol by left-clicking the line number.
      -- 4. In nvim, :lua require('dap').repl.toggle()
      -- 5. Or if the repl is not enough, run `dlv connect 127.0.0.1:38697`.
      --
      -- The workflow of debug a test is:
      -- 1. In nvim, set breakpoints with statuscol by left-clicking the line number.
      -- 2. In nvim, :lua require('dap').continue() and select the configuration 'Debug test'.
      port = "38697",
    },
    dap_configurations = {
      {
        type = "go",
        request = "attach",
        name = "attach-remote-delve",
        -- https://github.com/go-delve/delve/blob/b5c9edccffb8d6903811d7dacbc38a2076f61382/service/dap/server.go#L1813
        mode = "remote",
      },
    },
  })

  local dap = require("dap")
  local make_repeatable = require("dot-repeat").make_repeatable

  local actions = {
    continue = make_repeatable("dap_continue", dap.continue),
    step_over = make_repeatable("dap_step_over", dap.step_over),
    step_into = make_repeatable("dap_step_into", dap.step_into),
    step_out = make_repeatable("dap_step_out", dap.step_out),
    toggle = make_repeatable("dap_toggle", dap.repl.toggle),
    hover = make_repeatable("dap_hover", require("dap.ui.widgets").hover),
  }
  return actions
end)

vim.keymap.set("n", "<Leader>dc", function()
  return setup().continue()
end, { expr = true, desc = "Debugger: Continue" })

vim.keymap.set("n", "<Leader>db", function()
  return setup().step_over()
end, { expr = true, desc = "Debugger: Step over (beyond)" })

vim.keymap.set("n", "<Leader>di", function()
  return setup().step_into()
end, { expr = true, desc = "Debugger: Step into" })

vim.keymap.set("n", "<Leader>do", function()
  return setup().step_out()
end, { expr = true, desc = "Debugger: Step out" })
vim.keymap.set({ "n", "x" }, "<Leader>dK", function()
  return setup().hover()
end, { expr = true, desc = "Debugger: Hover" })
