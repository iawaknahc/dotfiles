;;; -*- lexical-binding: t -*-

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-auto-save-mode)
(require 'init-interlocking)
(require 'init-macos)
(require 'init-theme)
(require 'init-ui)
(require 'init-tab-bar)
(require 'init-echo-area)
(require 'init-display-line-numbers-mode)
(require 'init-what-cursor-position)

;; Completion
(require 'init-completion-at-point)
(require 'init-completion-at-point-functions)
(require 'init-completing-read)
(require 'init-completion-styles)
(require 'init-annotation-function)
(require 'init-display-sort-function)
(require 'init-elisp-completion-at-point)

(require 'init-treesitter)
(require 'init-scrolling)
(require 'init-mu4e)
;; It seems that corfu is not compatible with evil.
;; In evil insert state, C-n is taken by evil, not corfu.
;(require 'init-evil)

(provide 'init)
