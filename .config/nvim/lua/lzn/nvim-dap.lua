local dap_go_options = {
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
}

require("lz.n").load({
  "nvim-dap-go",
  lazy = true,
  after = function()
    require("dap-go").setup(dap_go_options)
  end,
})

require("lz.n").load({
  "nvim-dap",
  after = function()
    require("lz.n").trigger_load("nvim-dap-go")
  end,
  event = { "DeferredUIEnter" },
  keys = {
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Debugger continue",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Debugger step over",
    },
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Debugger step into",
    },
    {
      "<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "Debugger step out",
    },
    {
      "<Space>R",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Debugger toggle REPL",
    },
    {
      "<Space>K",
      function()
        require("dap.ui.widgets").hover()
      end,
      mode = { "n", "v" },
      desc = "Debugger hover",
    },
  },
})
