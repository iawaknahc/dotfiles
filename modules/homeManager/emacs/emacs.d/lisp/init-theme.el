;;; init-theme.el --- init-theme.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar catppuccin-flavor)
(defvar catppuccin-italic-comments)
(declare-function catppuccin-color "catppuccin-theme")
(declare-function catppuccin-reload "catppuccin-theme")

(setq
 ;; See the comment on `org-clock-clocked-in-display'.
 frame-resize-pixelwise t

 window-system-default-frame-alist
 '((ns . (;; Make the title bar and the scroll bar transparent,
          ;; and make them take the color of the background of the theme.
          (ns-transparent-titlebar . t)
          ;; Make the text color of the title bar readable.
          ;; Otherwise, it is a dark color in a dark background.
          (ns-appearance . dark)))))

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
