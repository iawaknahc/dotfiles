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

function config()
  local lspconfig = require('lspconfig')

  for i, v in ipairs(simple) do
    lspconfig[v].setup {}
  end

  lspconfig["tsserver"].setup {
    root_dir = lspconfig.util.root_pattern("package.json"),
  }
  lspconfig["denols"].setup {
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
  }

  local lspGroup = vim.api.nvim_create_augroup("MyLSPAutoCommands", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = lspGroup,
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      local map_opts = { noremap = true, buffer = bufnr }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, map_opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, map_opts)
      vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, map_opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, map_opts)
      -- signature_help is handled by lsp_signature
      -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, map_opts)
      -- implementation is usually a list. It is handled by telescope.
      -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, map_opts)
      vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, map_opts)
      vim.keymap.set('n', 'g?', vim.diagnostic.open_float, map_opts)
      -- gopls supports rename.
      vim.keymap.set('n', 'grn', vim.lsp.buf.rename, map_opts)
      -- Most LSP servers do not provide code action.
      -- vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, map_opts)
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
      vim.bo[bufnr].fixendofline = true

      if client.name == "gopls" then
        vim.api.nvim_create_autocmd("BufWritePost", {
          group = lspGroup,
          callback = function()
            vim.lsp.buf.format()
          end,
        })
      end

    end,
  })
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
