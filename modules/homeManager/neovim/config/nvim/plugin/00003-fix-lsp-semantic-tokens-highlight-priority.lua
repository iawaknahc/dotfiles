-- In a Nix file, `# TODO` is recognized as @lsp.type.comment.nix (which links to @comment) and `@comment.todo`.
-- The fg color of `@comment.todo` SHOULD have a higher priority than that of @lsp.type.comment.nix,
-- but since semantic tokens has higher priority, the normal fg color of comment is used instead.
-- This results in a very pale text color on a colored background, making the text very difficult to read.
--
-- In a Lua file, it is common to have vim.cmd([[ some vimscript ]])
-- If the LSP language reports the vimscript snippet as @lsp.type.string,
-- then the treesitter highlight of the vimscript is lost.
--
-- In a Go file, if gopls settings semanticTokens is turned on,
-- all string literals are reported as @lsp.type.string.go (which links to String).
-- However, the treesitter parser of Go can report escape sequence in the string as @string.escape.go,
-- enabling highlighting of the escape sequences.
-- In fact, Gopls introduces ad-hoc settings like noSemanticString and noSemanticNumber to address this.
-- See https://github.com/golang/go/issues/45753
--
-- The above mentioned problems share the same root cause, that is,
-- the highlighting information of LSP semantic tokens is not as good as that of treesitter.
-- In those case, we want to flavor treesitter over LSP semantic tokens.
--
-- As far as I know, there are 2 approaches to solve this.
--
-- The first one is to lower the priority of semantic tokens, by setting vim.hl.priorities.semantic_tokens to a lower value.
-- But this would lower the priority of all semantic tokens.
--
-- The third one is to unlink @lsp.type.comment, @lsp.type.string, and @lsp.type.number
-- This preciously resolve the priority conflicts between treesitter and LSP semantic tokens on these known cases.
vim.cmd([[
highlight link @lsp.type.comment NONE
highlight link @lsp.type.string NONE
highlight link @lsp.type.number NONE
]])
