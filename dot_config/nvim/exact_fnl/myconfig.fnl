;;; Local macros
(macro seto! [name value]
  `(set (. vim.o ,name) ,value))

(macro setbo! [name value]
  `(set (. vim.bo ,name) ,value))

(macro setopt! [name value]
  `(set (. vim.opt ,name) ,value))

(macro cmd! [name ...]
  `((. vim.cmd ,name) ,...))

(macro keymap! [...]
  `(vim.keymap.set ,...))

(macro usercmd! [...]
  `(vim.api.nvim_create_user_command ,...))

(macro augroup! [...]
  `(vim.api.nvim_create_augroup ,...))

(macro autocmd! [...]
  `(vim.api.nvim_create_autocmd ,...))

;;; Configuration begins

;; The default is :filetype detection:ON plugin:ON indent:ON
;; We want to turn off indent.
(cmd! :filetype :indent :off)

;; Legacy syntax is turned on by default (:h nvim-defaults).
;; We want to turn it off here.
;; If we run :scriptnames, we see synload.vim is still sourced.
;; This is probably due to this trick.
;; https://github.com/neovim/neovim/blob/v0.10.1/runtime/lua/vim/treesitter/highlighter.lua#L138
(cmd! :syntax :off)

;; Security
;; https://github.com/numirias/security/blob/master/doc/2019-06-04_ace-vim-neovim.md
(seto! :modeline false)

;;; Look
;; Always reserve 1 column for vim-gitgutter and 2 columns for vim.diagnostic
(seto! :signcolumn "auto:3-9")
;; The default is 4.
(seto! :numberwidth 1)
(seto! :number true)
(seto! :list true)
;; lead:. is taken from the help of neovim.
;; trail:- is the default of neovim.
;; nbsp:+ is the default of neovim.
;; tab:>  is the default of neovim. We change it to tab:>_ so that
;; the space is visible and distinguishable from leading spaces.
(setopt! :listchars {:tab ">_" :lead "." :trail "-" :nbsp "+"})

(seto! :breakindent true)
(cmd! :colorscheme :mydracula)

;; colorcolumn
(let [colorcolumn (fcollect [i 1 100] (.. "+" i))]
  (setopt! :colorcolumn colorcolumn))

;;; Completion
(setopt! :completeopt [:menu :menuone :noselect])
(seto! :pumheight 10)

;;; Command mode
;; shell by default is $SHELL.
;; But I do not want neovim to run command with fish.
(seto! :shell :sh)
(setopt! :wildmode ["longest:full" :full])

;;; Editing
(seto! :backup false)
(seto! :writebackup false)
(seto! :swapfile false)
;; This controls how often the swapfile is written.
;; This also controls how often vim-gitgutter updates the signs.
;; :h updatetime
(seto! :updatetime 100)
(seto! :scrolloff 5)
(seto! :foldenable false)
(vim.opt.clipboard:append [:unnamed])
(seto! :fixendofline false)
;; Make ~ an operator
(seto! :tildeop true)

;;; Search
(seto! :ignorecase true)
(seto! :smartcase true)
(seto! :wrapscan false)

;;; Mapping
(keymap! :n :<Space> :<Nop> {:desc "Disable :h <Space>"})

(keymap! :n :gh :<Nop> {:desc "Disable :h gh"})

(keymap! :n :gH :<Nop> {:desc "Disable :h gH"})

(keymap! :n :g<C-h> :<Nop> {:desc "Disable :h g_CTRL-H"})

(keymap! :n :<C-l> "<Cmd>set hlsearch!<Bar>diffupdate<Bar>normal! <C-L><CR>"
         {:desc ":h CTRL-L-default with nohlsearch changed to hlsearch!"})

;;; User commands
(usercmd! :Space (fn [t]
                   (let [n (tonumber (. t.fargs 1))]
                     (if (not= n nil)
                         (do
                           (setbo! :tabstop n)
                           (setbo! :shiftwidth n)
                           (setbo! :softtabstop n)
                           (setbo! :expandtab true)))))
          {:nargs 1})

(usercmd! :Tab (fn [t]
                 (let [n (tonumber (. t.fargs 1))]
                   (if (not= n nil)
                       (do
                         (setbo! :tabstop n)
                         (setbo! :shiftwidth n)
                         (setbo! :softtabstop n)
                         (setbo! :expandtab false)))))
          {:nargs 1})

;; :HighlightGroupAtCursor prints out the highlight groups at cursor.
;; Useful for debugging colorscheme.
;; The motivation was to debug why @diff.plus has a different green color from the colorscheme.
(usercmd! :HighlightGroupAtCursor
          (fn []
            (-> (vim.treesitter.get_captures_at_cursor)
                (vim.inspect)
                (print))) {:nargs 0})

;;; Diagnostic
(vim.diagnostic.config {:virtual_text {:source true}
                        :float {:source true}
                        :severity_sort true})

;;; Autocmds

;; By default, filetype.vim treats *.env as sh
;; We do NOT want to run any before-save fix on *.env
;; For example, some envvars may have trailing whitespaces we do want to preserve.
(autocmd! [:BufNewFile :BufRead]
          {:pattern :*.env
           :callback (fn [] (setbo! :filetype ""))
           :group (augroup! :MyDotEnv {:clear true})})

(autocmd! [:BufNewFile :BufRead]
          {:pattern :*.cheat
           :callback (fn [] (setbo! :filetype :sh))
           :group (augroup! :MyNaviCheat {:clear true})})

(autocmd! [:TextYankPost]
          {:pattern "*"
           :callback (fn [] (vim.highlight.on_yank))
           :group (augroup! :MyYankHighlight {:clear true})})

(autocmd! [:DiagnosticChanged]
          {:callback (fn [] (vim.diagnostic.setloclist {:open false}))
           :group (augroup! :MyDiagnostic {:clear true})})

;; Return nil because this module is intended for side effects.
nil
