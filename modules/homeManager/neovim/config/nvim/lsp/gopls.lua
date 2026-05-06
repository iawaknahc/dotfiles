return {
  settings = {
    gopls = {
      semanticTokens = true,
      -- No need to turn off @lsp.type.string and @lsp.type.number because we handled them in the LSP client side.
      -- semanticTokenTypes = {
      --   string = false,
      --   number = false,
      -- },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
