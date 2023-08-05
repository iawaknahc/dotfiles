function config()
  local lspconfig = require('lspconfig')

  local disable_formatting = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end

  -- Data
  lspconfig["jsonls"].setup {
    on_attach = disable_formatting,
  }
  lspconfig["yamlls"].setup {
    on_attach = disable_formatting,
  }
  lspconfig["taplo"].setup {
    on_attach = disable_formatting,
  }

  -- Scripting
  lspconfig["awk_ls"].setup {
    on_attach = disable_formatting,
  }
  lspconfig["bashls"].setup {
    on_attach = disable_formatting,
  }

  -- SQL
  lspconfig["sqlls"].setup {
    on_attach = disable_formatting,
  }

  -- GraphQL
  lspconfig["graphql"].setup {
    on_attach = disable_formatting,
  }

  -- Markup
  lspconfig["html"].setup {
    on_attach = disable_formatting,
  }
  lspconfig["cssls"].setup {}
  lspconfig["tailwindcss"].setup {}

  -- Programming
  lspconfig["gopls"].setup {}
  lspconfig["tsserver"].setup {
    on_attach = disable_formatting,
    root_dir = lspconfig.util.root_pattern("package.json"),
  }
  lspconfig["denols"].setup {
    on_attach = disable_formatting,
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  }
  lspconfig["pyright"].setup {}
  lspconfig["clojure_lsp"].setup {}
  lspconfig["rust_analyzer"].setup {}
  lspconfig["dartls"].setup {}
  lspconfig["ocamllsp"].setup {}
  lspconfig["sourcekit"].setup {}
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
