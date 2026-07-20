;;; init.el --- My init.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Configure features that come with Emacs.
(require 'init-keymap)
(require 'init-shell)
(require 'init-auto-save-mode)
(require 'init-auto-revert-mode)
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
(require 'init-whitespace)
(require 'init-show-paren)
(require 'init-electric-pair-mode)
(require 'init-indent-tabs-mode)
(require 'init-help)
(require 'init-info)
(require 'init-eldoc)
(require 'init-eval-expression)
(require 'init-compilation-mode)
(require 'init-grep-mode)

;; Configure completion.
(require 'init-completion-at-point)
(require 'init-completion-at-point-functions)
(require 'init-completing-read)
(require 'init-completion-styles)
(require 'init-annotation-function)
(require 'init-display-sort-function)
(require 'init-elisp-completion-at-point)
(require 'init-embark)
(require 'init-consult)

;; Configure treesitter.
(require 'init-treesitter)

;; Configure scrolling.
(require 'init-scrolling)

;; Configure modal editing.
(require 'init-evil)

;; Configure format after save.
(require 'init-apheleia)

;; Configure on-the-fly checking.
(require 'init-flycheck)

;; FIXME: Switch to grep-edit-mode in Emacs 31.
;; Configure wgrep.el
(require 'init-wgrep)

;; Configure rainbow parenthesis.
(require 'init-rainbow-delimiters)

;; Configure Git integration.
(require 'init-diff-hl)

;; Configure email client.
(require 'init-mu4e)

(provide 'init)
;;; init.el ends here
