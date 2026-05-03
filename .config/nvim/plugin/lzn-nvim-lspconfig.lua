-- On 2025-06-24, I tried neovim 0.11 :h lsp-completion
-- The autocomplete without configuration depends on the language server's triggerCharacters.
-- It is very common that you hit backspace to delete some characters, and expect the completion to continues.
-- This is not possible out-of-the-box.
-- Thus, an autocompletion plugin is still needed to fill this gap.
--
-- ---@type table<integer, string>
-- local kind_int_to_string = {}
-- for string_, int_ in pairs(vim.lsp.protocol.CompletionItemKind) do
--   kind_int_to_string[int_] = string_
-- end
--
-- vim.lsp.config("*", {
--   on_attach = function(client, bufnr)
--     if client:supports_method("textDocument/completion") then
--       vim.lsp.completion.enable(true, client.id, bufnr, {
--         autotrigger = true,
--
--         -- https://github.com/neovim/neovim/blob/v0.11.2/runtime/lua/vim/lsp/completion.lua#L328
--         ---@param item lsp.CompletionItem
--         ---@return table :h complete-items
--         convert = function(item)
--           return {
--             abbr = item.label:gsub("%b()", ""),
--             -- Use catppuccin integration with blink.cmp to do highlight.
--             -- https://github.com/catppuccin/nvim/blob/v1.10.0/lua/catppuccin/groups/integrations/blink_cmp.lua
--             abbr_hlgroup = "BlinkCmpLabel",
--             kind_hlgroup = "BlinkCmpKind" .. (kind_int_to_string[item.kind] or "Unknown"),
--           }
--         end,
--       })
--     end
--   end,
-- })

vim.lsp.enable("awk_ls")
vim.lsp.enable("bashls")
vim.lsp.enable("clojure_lsp")
vim.lsp.enable("codebook")
vim.lsp.enable("cssls")
vim.lsp.enable("dartls")
vim.lsp.enable("denols")
vim.lsp.enable("docker_compose_language_service")
vim.lsp.enable("dockerls")
vim.lsp.enable("emmylua_ls")
vim.lsp.enable("eslint")
vim.lsp.enable("fennel_ls")
vim.lsp.enable("fish_lsp")
vim.lsp.enable("gopls")
vim.lsp.enable("graphql")
vim.lsp.enable("harper_ls")
vim.lsp.enable("html")
vim.lsp.enable("jdtls")
vim.lsp.enable("jsonls")
vim.lsp.enable("markdown_oxide")
vim.lsp.enable("nil_ls")
vim.lsp.enable("nixd")
vim.lsp.enable("pyright")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("sourcekit")
vim.lsp.enable("sqls")
vim.lsp.enable("stylua")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("taplo")
vim.lsp.enable("typos_lsp")
vim.lsp.enable("vtsls")
vim.lsp.enable("yamlls")
vim.lsp.enable("zls")

local group = vim.api.nvim_create_augroup("MyLSP", { clear = true })
local function format_on_save(lsp_name, pattern)
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    pattern = pattern,
    callback = function(ev)
      local clients = vim.lsp.get_clients({ name = lsp_name, bufnr = ev.buf })
      if #clients == 1 then
        vim.lsp.buf.format({ bufnr = ev.buf, client = clients[1].id, timeout_ms = 1000 })
      end
    end,
  })
end

format_on_save("clojure_lsp", "*.clj")
format_on_save("dartls", "*.dart")
format_on_save("fish_lsp", "*.fish")
format_on_save("gopls", "*.go,go.mod,go.sum,go.work,go.work.sum")
format_on_save("nixd", "*.nix")
format_on_save("rust_analyzer", "*.rs")
format_on_save("stylua", "*.lua")
format_on_save("zls", "*.zig")
