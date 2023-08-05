return {
  {
    'jayp0521/mason-null-ls.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'jose-elias-alvarez/null-ls.nvim',
    },
    opts = {
      automatic_installation = true,
    },
    main = 'mason-null-ls',
  },
}
