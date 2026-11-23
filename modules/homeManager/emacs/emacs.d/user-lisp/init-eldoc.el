;;; init-eldoc.el --- init-eldoc.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Show all ElDoc messages.
(setq eldoc-documentation-strategy 'eldoc-documentation-compose)
;; I tried setting it to 0.
;; In a real programming session,
;; it is very annoying.
;; For example, when I spam C-n to move point, it flickers.
(setq eldoc-idle-delay 0.5)
;; Allow ElDoc to resize echo area.
(setq eldoc-echo-area-use-multiline-p t)
;; Do not show in echo area if Eldoc buffer is being shown.
(setq eldoc-echo-area-prefer-doc-buffer t)

(provide 'init-eldoc)
;;; init-eldoc.el ends here
