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
(require 'init-treesitter)
(require 'init-scrolling)
(require 'init-mu4e)
(require 'init-evil)

(provide 'init)
