return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    cmd = {
      "Mason",
    },
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    main = "mason-nvim-dap",
    opts = {
      ensure_installed = {
        "delve",
      },
    },
  },
}
