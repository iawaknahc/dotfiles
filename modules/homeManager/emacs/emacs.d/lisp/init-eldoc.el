;;; init-eldoc.el --- init-eldoc.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
  eldoc
  :ensure nil
  :custom
  ;; Show all ElDoc messages.
  (eldoc-documentation-strategy 'eldoc-documentation-compose)
  ;; Show ElDoc immediately.
  (eldoc-idle-delay 0)
  ;; Allow ElDoc to resize echo area.
  (eldoc-echo-area-use-multiline-p t)
  :config
  (add-to-list
   'display-buffer-alist
   `(,(rx string-start "*eldoc")
     (display-buffer-reuse-window display-buffer-in-side-window)
     (side . bottom)
     (reusable-frames . visible)
     (window-height . 0.2))))

(provide 'init-eldoc)
;;; init-eldoc.el ends here
