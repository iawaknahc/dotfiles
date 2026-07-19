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
;;; Code:

(use-package
  flycheck
  :ensure nil
  :hook ((prog-mode . flycheck-mode)
         (text-mode . flycheck-mode))
  :custom
  (flycheck-indication-mode 'left-margin)
  ;; Display error in the echo area without delay.
  (flycheck-display-errors-delay 0)
  :config
  (add-to-list
   'display-buffer-alist
   `(,(rx "*Flycheck errors*")
     (display-buffer-reuse-window display-buffer-in-side-window)
     (side . bottom)
     (reusable-frames . visible)
     (window-height . 0.33))))

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
