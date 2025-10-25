require("lz.n").load({
  "nvim-dap-go",
  lazy = true,
  after = function()
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
  end,
})

require("lz.n").load({
  "nvim-dap-python",
  lazy = true,
  after = function()
    require("dap-python").setup("debugpy-adapter")
  end,
})

require("lz.n").load({
  "nvim-dap",
  enabled = vim.g.pager_enabled ~= 1,
  event = { "DeferredUIEnter" },
  after = function()
    require("lz.n").trigger_load("nvim-dap-go")
    require("lz.n").trigger_load("nvim-dap-python")

    local make_repeatable = require("dot-repeat").make_repeatable

    vim.keymap.set(
      "n",
      "<Leader>dc",
      make_repeatable("dap_continue", function()
        require("dap").continue()
      end),
      { expr = true, desc = "Debugger: Continue" }
    )

    vim.keymap.set(
      "n",
      "<Leader>db",
      make_repeatable("dap_step_over", function()
        require("dap").step_over()
      end),
      { expr = true, desc = "Debugger: Step over (beyond)" }
    )

    vim.keymap.set(
      "n",
      "<Leader>di",
      make_repeatable("dap_step_into", function()
        require("dap").step_into()
      end),
      { expr = true, desc = "Debugger: Step into" }
    )

    vim.keymap.set(
      "n",
      "<Leader>do",
      make_repeatable("dap_step_out", function()
        require("dap").step_out()
      end),
      { expr = true, desc = "Debugger: Step out" }
    )

    vim.keymap.set(
      "n",
      "<Leader>dr",
      make_repeatable("dap_toggle", function()
        require("dap").repl.toggle()
      end),
      { expr = true, desc = "Debugger: Toggle REPL" }
    )

    vim.keymap.set(
      { "n", "x" },
      "<Leader>dK",
      make_repeatable("dap_hover", function()
        require("dap.ui.widgets").hover()
      end),
      { expr = true, desc = "Debugger: Hover" }
    )
  end,
})
