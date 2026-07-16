;;; init-apheleia.el --- init-apheleia.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 apheleia
 :ensure nil
 :hook ((prog-mode . apheleia-mode)
        (text-mode . apheleia-mode))
 :config
 (push '(fnlfmt "fnlfmt" "-") apheleia-formatters)
 (push '(nufmt "nufmt" file) apheleia-formatters)
 (setf (alist-get 'python-mode apheleia-mode-alist)
       '(ruff-isort ruff))
 (setf (alist-get 'python-ts-mode apheleia-mode-alist)
       '(ruff-isort ruff))
 (setf (alist-get 'emacs-lisp-mode apheleia-mode-alist)
       'cljfmt)
 (push '(nushell-ts-mode . nufmt) apheleia-mode-alist)
 (push '(fennel-mode . fnlfmt) apheleia-mode-alist))

(provide 'init-apheleia)
;;; init-apheleia.el ends here
