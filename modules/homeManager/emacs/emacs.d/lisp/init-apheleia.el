;;; init-apheleia.el --- init-apheleia.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-hook 'prog-mode-hook #'apheleia-mode)
(add-hook 'text-mode-hook #'apheleia-mode)

(with-eval-after-load 'apheleia
  (push '(fnlfmt "fnlfmt" "-") apheleia-formatters)
  (push '(nufmt "nufmt" file) apheleia-formatters)
  (setf (alist-get 'python-mode apheleia-mode-alist)
        '(ruff-isort ruff))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist)
        '(ruff-isort ruff))
  (push '(nushell-ts-mode . nufmt) apheleia-mode-alist)
  (push '(fennel-mode . fnlfmt) apheleia-mode-alist))

(provide 'init-apheleia)
;;; init-apheleia.el ends here
