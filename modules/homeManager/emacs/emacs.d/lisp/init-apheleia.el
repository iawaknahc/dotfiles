;;; init-apheleia.el --- init-apheleia.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-hook 'prog-mode-hook #'apheleia-mode)
(add-hook 'text-mode-hook #'apheleia-mode)

;; Alpheleia is written in a way that even apheleia-mode is autoloaded,
;; most of its dependencies are not loaded until the first save.
;; Therefore, `apheleia-formatters' and `apheleia-mode-alist' only exist
;; when we actually save a file, or invoke (require apheleia) directly.
(with-eval-after-load 'apheleia
  ;; These formatters are not included by default.
  (setf (alist-get 'fnlfmt apheleia-formatters) '("fnlfmt" "-"))
  (setf (alist-get 'nufmt apheleia-formatters) '("nufmt" file))

  ;; The built-in stylua configuration is '("stylua" "-"), which is too simple.
  ;; Use the configuration from conform.nvim
  ;; See https://github.com/stevearc/conform.nvim/blob/v9.1.0/lua/conform/formatters/stylua.lua
  (setf (alist-get 'stylua apheleia-formatters) '("stylua" "--search-parent-directories" "--respect-ignores" "--stdin-filepath" filepath "-"))

  ;; The built-in ruff formatter uses `fill-column' as line-length.
  ;; We want ruff to behave deterministically.
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff"
          "format"
          "--force-exclude"
          "--stdin-filename" filepath
          "-"))

  ;; The built-in ruff-sort formatter selects I.
  ;; Here we select I001.
  ;; See https://docs.astral.sh/ruff/rules/#isort-i
  (setf (alist-get 'ruff-sort apheleia-formatters)
        '(
          "ruff"
          "check"
          "--fix"
          "--fix-only"
          "--force-exclude"
          "--select=I001"
          "--no-cache"
          "--exit-zero"
          "--stdin-filename" filepath
          "-"))

  ;; The built-in prettier formatters pass --use-tabs conditionally.
  ;; We do not want that.
  (setf (alist-get 'prettier-javascript apheleia-formatters)
        '(
          "apheleia-npx"
          "prettier"
          "--parser=babel"
          "--stdin-filepath" filepath))
  (setf (alist-get 'prettier-typescript apheleia-formatters)
        '(
          "apheleia-npx"
          "prettier"
          "--parser=typescript"
          "--stdin-filepath" filepath))
  (setf (alist-get 'prettier-css apheleia-formatters)
        '(
          "apheleia-npx"
          "prettier"
          "--parser=css"
          "--stdin-filepath" filepath))

  ;; The built-in bean-format formatter uses input.
  ;; But it actually supports reading from stdin directly.
  (setf (alist-get 'bean-format apheleia-formatters)
        '("bean-format" "-"))

  ;; Replace `apheleia-mode-alist' with the following value.
  ;; By default, apheleia-mode-alist is pre-configured with many formatters for many major modes.
  ;; Keeping them enabled will definitely interfere with LSP.
  (setq
   apheleia-mode-alist
   '(
     ;; Python
     (python-mode . (ruff-isort ruff))
     (python-ts-mode . (ruff-isort ruff))
     ;; Nushell
     (nushell-ts-mode . nufmt)
     ;; Fennel
     (fennel-mode . fnlfmt)
     ;; Beancount
     (beancount-mode . bean-format)
     ;; Lua
     (lua-mode . stylua)
     (lua-ts-mode . stylua)
     ;; Lisp
     (lisp-mode . lisp-indent)
     (emacs-lisp-mode . lisp-indent)
     (lisp-mode . lisp-indent)
     ;; Prettier
     (css-mode . prettier-css)
     (css-ts-mode . prettier-css)
     (js-mode . prettier-javascript)
     (js-ts-mode . prettier-javascript)
     (js-jsx-mode . prettier-javascript)
     (typescript-mode . prettier-typescript)
     (typescript-ts-mode . prettier-typescript)
     (tsx-ts-mode . prettier-typescript))))


(provide 'init-apheleia)
;;; init-apheleia.el ends here
