return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    main = "mason-lspconfig",
    opts = {
      automatic_installation = true,
    },
  },
}
