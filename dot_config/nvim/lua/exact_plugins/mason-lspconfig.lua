return {
  {
    "williamboman/mason-lspconfig.nvim",
    -- We used to use cmd={"Mason"} to lazy-load, but
    -- using cmd={"Mason"} in mason and its companion plugins seem confuse lazy.nvim.
    event = {
      "VeryLazy",
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
    main = "mason-lspconfig",
    opts = {
      automatic_installation = true,
    },
  },
}
