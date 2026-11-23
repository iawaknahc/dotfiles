;;; init.el --- My init.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;;; Security
;; No directories are safe.
(setq safe-local-variable-directories nil)
;; Disable dir-local variables in remote files.
(setq enable-remote-dir-locals nil)

;; :safe means allow `safe-local-variable-values' and `enable-local-eval'.
;; If it is nil, then `enable-local-eval' is completely ignored.
(setq enable-local-variables :safe)

;; Allow `org-agenda-skip-archived-trees' to be set.
;; This enables a use case where we want to use :ARCHIVE: on a headline to
;; make S-TAB does not cycle on the headline.
;; But we still want the agenda view to treat it as not archived.
(setq safe-local-variable-values
      '((org-agenda-skip-archived-trees . nil)
        (org-agenda-skip-archived-trees . t)))

;; Always allow `lexical-binding' and `read-symbol-shorthands'.
;; This is the default.
(setq permanently-enabled-local-variables '(lexical-binding read-symbol-shorthands))

;; Unless allowed in `safe-local-eval-forms', ask first.
(setq enable-local-eval :x-ask-me-first)
;; Allow starting Org in Columns View.
(setq safe-local-eval-forms '((org-columns)))

;; Trust only the code I wrote.
;; This affects the return value of `trusted-content-p'.
;; As far as I know, users are `elisp-flymake-byte-compile' and `elisp-completion-at-point'.
;; The expected result is that no macros will be expanded.
;; See https://eshelyaron.com/posts/2024-11-27-emacs-aritrary-code-execution-and-how-to-avoid-it.html
(setq trusted-content '("~/dotfiles/modules/homeManager/emacs/emacs.d/"))

;; Teach `elisp-flymake-byte-compile' on how to load my Elisp files.
(setq elisp-flymake-byte-compile-load-path
      '("./"
        "~/dotfiles/modules/homeManager/emacs/emacs.d/user-lisp/"))

;;;; Other configurations

;; When using the NS build on macOS, and
;; the application is launched by Spotlight or something similar,
;; the environment variables are minimal.
;; We need the environment variables initialized like in a shell.
;; There is a third party package `exec-path-from-shell' designed exactly for this purpose.
;; To keep environment variables synced with my Nix configuration,
;; this file is generated in Nix.
;;
;; For example, vulpea needs PATH to find fswatch,
;; mu4e needs PATH to find mbsync.
(require 'init-exec-path-from-shell)

;; Theme must be configured BEFORE font.
;; It is because `set-face-attribute' is used on the face `default'.
;; If the theme call `set-face-attribute' on the face `default',
;; my font configuration may be altered.
(require 'init-theme)
(require 'init-font)

;; Configure features that come with Emacs.
(require 'init-timezone)
(require 'init-keymap)
(require 'init-shell)
(require 'init-auto-save-mode)
(require 'init-auto-revert-mode)
(require 'init-backup-files)
(require 'init-interlocking)
(require 'init-macos)
(require 'init-bell)
(require 'init-tool-bar-mode)
(require 'init-startup-screen)
(require 'init-tab-bar)
(require 'init-echo-area)
(require 'init-display-line-numbers-mode)
(require 'init-margin)
(require 'init-what-cursor-position)
(require 'init-dired)
(require 'init-recentf)
(require 'init-project)
(require 'init-whitespace-mode)
(require 'init-tidy-whitespace)
(require 'init-show-paren)
(require 'init-electric-pair-mode)
(require 'init-indent-tabs-mode)
(require 'init-sh-mode)
(require 'init-help)
(require 'init-info)
(require 'init-eldoc)
(require 'init-eval-expression)
(require 'init-compilation-mode)
(require 'init-grep-mode)
(require 'init-flymake)
(require 'init-eglot)
(require 'init-server)
(require 'init-org-mode)
(require 'init-calc)
(require 'init-switch-to-buffer)
(require 'init-display-buffer)
(require 'init-lisp-interaction-mode)
(require 'init-ediff)
(require 'init-mode-line)
(require 'init-visual-line-mode)
(require 'init-calendar)
(require 'init-scroll-bar-mode)
(require 'init-search)
(require 'init-repeat-mode)
(require 'init-savehist-mode)
(require 'init-save-place-mode)
(require 'init-flyspell)
(require 'init-thingatpt)
(require 'init-world-clock-mode)
(require 'init-editorconfig-mode)
(require 'init-goto-address-mode)
(require 'init-dabbrev)
(require 'init-so-long-mode)
(require 'init-menu-bar-mode)
(require 'init-doc-view-mode)
(require 'init-mwheel)

;; Configure folding
(require 'init-outline-minor-mode)
(require 'init-hideshow)

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

;; Configure Very Large File
(require 'init-vlf)

;; Configure snippet.
(require 'init-tempel)

;; Configure treesitter.
(require 'init-treesitter)

;; Configure modal editing.
(require 'init-evil)

;; Configure format after save.
(require 'init-apheleia)

;; Configure additional Flymake backends
(require 'init-flymake-quickdef)

;; Configure Git integration.
(require 'init-diff-hl)

;; Configure email client.
(require 'init-mu4e)
(require 'init-org-mime)

;; Configure terminal emulator.
(require 'init-ghostel)

(require 'init-launcher)

;; Configure input method.
(require 'init-input-method)

;; Configure vulpea
(require 'init-vulpea)

;; Configure Denote
(require 'init-denote)

;; Configure Magit
(require 'init-magit)

;; Configure beancount.
(require 'init-beancount)

;; Configure HTTP server
(require 'init-simple-httpd)

(provide 'init)
;;; init.el ends here
