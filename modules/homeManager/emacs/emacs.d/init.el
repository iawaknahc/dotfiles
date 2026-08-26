;;; init.el --- My init.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Security
(setq
 ;; No directories are safe.
 safe-local-variable-directories nil
 ;; Disable dir-local variables in remote files.
 enable-remote-dir-locals nil

 ;; :safe means allow `safe-local-variable-values' and `enable-local-eval'.
 ;; If it is nil, then `enable-local-eval' is completely ignored.
 enable-local-variables :safe
 ;; No values are safe.
 safe-local-variable-values nil
 ;; Always allow `lexical-binding' and `read-symbol-shorthands'.
 ;; This is the default.
 permanently-enabled-local-variables '(lexical-binding read-symbol-shorthands)

 ;; Unless allowed in `safe-local-eval-forms', ask first.
 enable-local-eval :x-ask-me-first
 ;; Allow starting Org in Columns View.
 safe-local-eval-forms '((org-columns))

 ;; Nothing is trusted.
 ;; This effects the return value of `trusted-content-p'.
 ;; As far as I know, users are `elisp-flymake-byte-compile' and `elisp-completion-at-point'.
 ;; The expected result is that no macros will be expanded.
 ;; See https://eshelyaron.com/posts/2024-11-27-emacs-aritrary-code-execution-and-how-to-avoid-it.html
 trusted-content nil)

;; I am aware that there is a User Lisp directory feature since Emacs 31.
;; But it is not suitable for putting configuration files.
;; I tried it and when Emacs starts, it generated a lot of warnings,
;; saying that a symbol from a third package is undefined.
;; Maybe this feature is for writing my own library packages.
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; When using the PGTK build on macOS, and
;; the application is launched by Spotlight or something similar,
;; the environment variables are minimal.
;; We need the environment variables initialized like in a shell.
;; There is a third party package `exec-path-from-shell' designed exactly for this purpose.
;; To keep environment variables synced with my Nix configuration,
;; this file is generated in Nix.
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
(require 'init-ui)
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
(require 'init-outline-minor-mode)

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

;; Configure snippet.
(require 'init-tempel)

;; Configure treesitter.
(require 'init-treesitter)

;; Configure scrolling.
(require 'init-scrolling)

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

(require 'init-launcher)

;; Configure input method.
(require 'init-input-method)

;; Configure vulpea
(require 'init-vulpea)

;; Configure Magit
(require 'init-magit)

;; Configure osm.el
(require 'init-osm)

(provide 'init)
;;; init.el ends here
