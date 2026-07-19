;;; init-shell.el --- init-shell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Always use /bin/sh, instead of reading SHELL.
(setq
 shell-file-name "/bin/sh"
 sh-shell-file "/bin/sh")

(provide 'init-shell)
;;; init-shell.el ends here
