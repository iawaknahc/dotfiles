return {
  {
    "williamboman/mason-lspconfig.nvim",
    cmd = {
      "Mason",
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
