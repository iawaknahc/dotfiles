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
  (setf (alist-get 'fnlfmt apheleia-formatters) '("fnlfmt" "-"))
  (setf (alist-get 'nufmt apheleia-formatters) '("nufmt" file))
  (setf (alist-get 'python-mode apheleia-mode-alist) '(ruff-isort ruff))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff))
  (setf (alist-get 'nushell-ts-mode apheleia-mode-alist) 'nufmt)
  (setf (alist-get 'fennel-mode apheleia-mode-alist) 'fnlfmt))

(provide 'init-apheleia)
;;; init-apheleia.el ends here
