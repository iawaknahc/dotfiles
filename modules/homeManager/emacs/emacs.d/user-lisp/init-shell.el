;;; init-shell.el --- init-shell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar sh-shell-file)

;; Always use /bin/sh, instead of reading SHELL.
(setq shell-file-name "/bin/sh")
(setq sh-shell-file "/bin/sh")

(provide 'init-shell)
;;; init-shell.el ends here
