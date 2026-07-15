;;; init-shell.el --- init-shell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 emacs
 :custom
 ;; Always use /bin/sh, instead of reading SHELL.
 (shell-file-name "/bin/sh")
 (sh-shell-file "/bin/sh"))

(provide 'init-shell)
;;; init-shell.el ends here
