;;; init-flycheck.el --- init-flycheck.el -*- lexical-binding: t -*-
;;
;;; Commentary:
;;
;; I tried flymake but it is too minimal.
;;
;; There are too few built-in checkers.
;; The way to define a backend is to write a function, which is too advanced.
;; When there are multiple backends, the default UI does not show which message produced by which backend.
;;
;; I also tried flycheck-inline.
;; It cannot be customized to achieve the existing UX I have in Neovim.
;; Namely, it can only display inline message where point is, and
;; the displayed message must be below the current line.
;;
;; The Emacs Lisp checker has a limitation of emitting false positives on autoloaded symbols.
;; The issue cannot be worked around even with `flycheck-emacs-lisp-initialize-packages' or `flycheck-emacs-lisp-load-path'.
;; See https://github.com/flycheck/flycheck/issues/2063
;;; Code:

(add-hook 'prog-mode-hook #'flycheck-mode)
(add-hook 'text-mode-hook #'flycheck-mode)

(setq
 flycheck-indication-mode 'left-margin
 ;; Display error at point without delay.
 flycheck-display-errors-delay 0
 ;; Always initialize packages because I manage my configuration with Nix.
 ;; The source of the configuration does not appear in user-init-file or user-emacs-directory.
 flycheck-emacs-lisp-initialize-packages t
 ;; Use the same load path.
 flycheck-emacs-lisp-load-path 'inherit)
;; FIXME: flycheck 37.0 has flycheck-error-list-display-buffer-action.
(add-to-list
 'display-buffer-alist
 `(,(rx string-start "*Flycheck errors*" string-end)
   (display-buffer-reuse-window display-buffer-in-side-window)
   (side . bottom)
   (window-height . 0.25)))

(defun my/flycheck-error-format-message-and-id (err &optional _include-snippet)
  "Override flycheck-error-format-message-and-id.
ERR is used while optional arguments are ignored."
  (let* ((level (flycheck-error-level err))
         (level-face (flycheck-error-level-error-list-face level))
         (formatted-level (propertize (upcase (symbol-name level)) 'face level-face))
         (checker (flycheck-error-checker err))
         (formatted-checker (propertize (symbol-name checker) 'face 'flycheck-error-list-checker-name))
         (id (or (flycheck-error-id err) "NO ID"))
         (formatted-id (propertize id 'face 'flycheck-error-list-id))
         (msg (or (flycheck-error-message err) "NO MESSAGE"))
         (formatted-msg (propertize msg 'face 'flycheck-error-list-error-message)))
    (format "[%s](%s)[%s] %s" formatted-level formatted-checker formatted-id formatted-msg)))

(advice-add 'flycheck-error-format-message-and-id :override 'my/flycheck-error-format-message-and-id)

(provide 'init-flycheck)
;;; init-flycheck.el ends here
