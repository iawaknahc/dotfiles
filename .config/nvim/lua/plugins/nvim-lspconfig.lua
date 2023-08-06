function config()
  local lspconfig = require('lspconfig')

  local simple = {
    -- Data
    'jsonls',
    'yamlls',
    'taplo',
    -- Scripting
    'awk_ls',
    'bashls',
    -- SQL
    'sqlls',
    -- GraphQL
    'graphql',
    -- Markup
    'html',
    'cssls',
    'tailwindcss',
    -- Programming
    'gopls',
    'pyright',
    'clojure_lsp',
    'rust_analyzer',
    'dartls',
    'ocamllsp',
    'sourcekit',
  }

  for i, v in ipairs(simple) do
    lspconfig[v].setup {}
  end

  lspconfig["tsserver"].setup {
    root_dir = lspconfig.util.root_pattern("package.json"),
  }
  lspconfig["denols"].setup {
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  }
end

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
    },
    config = config,
  }
}
