; The default is :filetype detection:ON plugin:ON indent:ON
; We want to turn off indent.
(vim.cmd.filetype :indent :off)


; Legacy syntax is turned on by default (:h nvim-defaults).
; We want to turn it off here.
; If we run :scriptnames, we see synload.vim is still sourced.
; This is probably due to this trick.
; https://github.com/neovim/neovim/blob/v0.10.1/runtime/lua/vim/treesitter/highlighter.lua#L138
(vim.cmd.syntax :off)


; Security
; https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
(set vim.o.modeline false)


; Look
; Always reserve 1 column for vim-gitgutter and 2 columns for vim.diagnostic
(set vim.o.signcolumn "auto:3-9")
; The default is 4.
(set vim.o.numberwidth 1)
(set vim.o.number true)
(set vim.o.list true)
; lead:. is taken from the help of neovim.
; trail:- is the default of neovim.
; nbsp:+ is the default of neovim.
; tab:>  is the default of neovim. We change it to tab:>_ so that
; the space is visible and distinguishable from leading spaces.
(set
  vim.opt.listchars
  {
  :tab ">_"
  :lead "."
  :trail "-"
  :nbsp "+"
  })
(set vim.o.breakindent true)
(vim.cmd.colorscheme "mydracula")


; colorcolumn
(local colorcolumn {})
(for [i 1 100]
  (table.insert colorcolumn (.. "+" i)))
(set vim.opt.colorcolumn colorcolumn)


; Completion
(set vim.opt.completeopt [:menu :menuone :noselect])
(set vim.o.pumheight 10)


; Command mode
; shell by default is $SHELL.
; But I do not want neovim to run command with fish.
(set vim.o.shell :sh)
(set vim.opt.wildmode ["longest:full" :full])


; Editing
(set vim.o.backup false)
(set vim.o.writebackup false)
(set vim.o.swapfile false)
; This controls how often the swapfile is written.
; This also controls how often vim-gitgutter updates the signs.
; :h updatetime
(set vim.o.updatetime 100)
(set vim.o.scrolloff 5)
(set vim.o.foldenable false)
(vim.opt.clipboard:append [:unnamed])
(set vim.o.fixendofline false)
; Make ~ an operator
(set vim.o.tildeop true)


; Search
(set vim.o.ignorecase true)
(set vim.o.smartcase true)
(set vim.o.wrapscan false)


; Mapping
(vim.keymap.set
  :n
  "<Space>"
  "<Nop>"
  {
  :desc "Disable :h <Space>"
  })
(vim.keymap.set
  :n
  "gh"
  "<Nop>"
  {
  :desc "Disable :h gh"
  })
(vim.keymap.set
  :n
  "gH"
  "<Nop>"
  {
  :desc "Disable :h gH"
  })
(vim.keymap.set
  :n
  "g<C-h>"
  "<Nop>"
  {
  :desc "Disable :h g_CTRL-H"
  })
(vim.keymap.set
  :n
  "<C-l>"
  "<Cmd>set hlsearch!<Bar>diffupdate<Bar>normal! <C-L><CR>"
  {
  :desc ":h CTRL-L-default with nohlsearch changed to hlsearch!"
  })


; Command
(vim.api.nvim_create_user_command
  "Space"
  (fn [t]
    (local n (tonumber (. t.fargs 1)))
    (if (not= n nil)
        (do
          (set vim.bo.tabstop n)
          (set vim.bo.shiftwidth n)
          (set vim.bo.softtabstop n)
          (set vim.bo.expandtab true)
          )))
  { :nargs 1 })
(vim.api.nvim_create_user_command
  "Tab"
  (fn [t]
    (local n (tonumber (. t.fargs 1)))
    (if (not= n nil)
        (do
          (set vim.bo.tabstop n)
          (set vim.bo.shiftwidth n)
          (set vim.bo.softtabstop n)
          (set vim.bo.expandtab false)
          )))
  { :nargs 1 })
; :HighlightGroupAtCursor prints out the highlight groups at cursor.
; Useful for debugging colorscheme.
; The motivation was to debug why @diff.plus has a different green color from the colorscheme.
(vim.api.nvim_create_user_command
  "HighlightGroupAtCursor"
  (fn []
    (-> (vim.treesitter.get_captures_at_cursor)
        (vim.inspect)
        (print)))
  { :nargs 0 })


; diagnostic
(vim.diagnostic.config
  {
  :virtual_text { :source true }
  :float { :source true }
  :severity_sort true
  })


; Set up autocommands
; By default, filetype.vim treats *.env as sh
; We do NOT want to run any before-save fix on *.env
; For example, some envvars may have trailing whitespaces we do want to preserve.
(vim.api.nvim_create_autocmd
  [:BufNewFile :BufRead]
  {
  :pattern "*.env"
  :callback (fn [] (set vim.bo.filetype ""))
  :group (vim.api.nvim_create_augroup "MyDotEnv" { :clear true })
  })
(vim.api.nvim_create_autocmd
  [:TextYankPost]
  {
  :pattern "*"
  :callback (fn [] (vim.highlight.on_yank))
  :group (vim.api.nvim_create_augroup "MyYankHighlight" { :clear true })
  })
(vim.api.nvim_create_autocmd
  [:DiagnosticChanged]
  {
  :callback (fn [] (vim.diagnostic.setloclist { :open false }))
  :group (vim.api.nvim_create_augroup "MyDiagnostic" { :clear true })
  })


; Return nil because this module is intended for side effects.
nil
