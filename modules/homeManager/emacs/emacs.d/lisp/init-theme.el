;;; init-theme.el --- init-theme.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(load-theme 'catppuccin :no-confirm)
(setq
 catppuccin-flavor 'mocha
 catppuccin-italic-comments t)
(catppuccin-reload)

;; As of 2026-10-11, Catppuccin does not support the following faces.
(custom-set-faces
 `(diary ((t (:foreground ,(catppuccin-color 'yellow)))))
 `(holiday ((t (:background ,(catppuccin-color 'overlay0)))))
 `(calendar-today ((t (:box (:line-width (-1 . -1) :color ,(catppuccin-color 'red)))))))

(provide 'init-theme)
;;; init-theme.el ends here
