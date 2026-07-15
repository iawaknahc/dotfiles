;;; init.el --- My init.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-auto-save-mode)
(require 'init-backup-files)
(require 'init-interlocking)
(require 'init-macos)
(require 'init-theme)
(require 'init-bell)
(require 'init-ui)
(require 'init-tab-bar)
(require 'init-echo-area)
(require 'init-display-line-numbers-mode)
(require 'init-what-cursor-position)
(require 'init-dired)
(require 'init-recentf)
(require 'init-project)

;; Completion
(require 'init-completion-at-point)
(require 'init-completion-at-point-functions)
(require 'init-completing-read)
(require 'init-completion-styles)
(require 'init-annotation-function)
(require 'init-display-sort-function)
(require 'init-elisp-completion-at-point)
(require 'init-embark)
(require 'init-consult)

(require 'init-treesitter)
(require 'init-scrolling)
(require 'init-mu4e)
(require 'init-diff-hl)

;; It seems that corfu is not compatible with evil.
;; In evil insert state, C-n is taken by evil, not corfu.
;(require 'init-evil)

(provide 'init)
;;; init.el ends here
