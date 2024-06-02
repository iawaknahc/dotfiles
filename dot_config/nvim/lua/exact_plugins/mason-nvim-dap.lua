return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- We used to use cmd={"Mason"} to lazy-load, but
    -- using cmd={"Mason"} in mason and its companion plugins seem confuse lazy.nvim.
    event = {
      "VeryLazy",
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
