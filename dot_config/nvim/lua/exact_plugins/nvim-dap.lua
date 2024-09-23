return {
  {
    "mfussenegger/nvim-dap",
    enabled = true,
    keys = {
      {
        "<F5>", function()
          require("dap").continue()
        end,
        desc = "Debugger continue",
      },
      {
        "<F10>", function()
          require("dap").step_over()
        end,
        desc = "Debugger step over",
      },
      {
        "<F11>", function()
          require("dap").step_into()
        end,
        desc = "Debugger step into",
      },
      {
        "<F12>", function()
          require("dap").step_out()
        end,
        desc = "Debugger step out",
      },
      {
        "<Leader>R", function()
          require("dap").repl.toggle()
        end,
        desc = "Debugger toggle REPL",
      },
      {
        "<Leader>K", function()
          require("dap.ui.widgets").hover()
        end,
        mode = {"n", "v"},
        desc = "Debugger hover",
      },
    },
    config = function() end,
  },
}
