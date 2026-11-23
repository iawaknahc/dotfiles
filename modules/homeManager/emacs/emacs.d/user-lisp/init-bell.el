;;; init-bell.el --- init-bell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar flash-face-attributes)
(defvar flash-face-faces)
(declare-function catppuccin-color "catppuccin-theme")

;; On NS build, the visible bell is a large image displayed at the center of the screen.
;; This is too annoying.
(setq visible-bell nil)
;; Flashing some faces to indicate a bell.
(setq ring-bell-function #'flash-face-bell-function)
;; Flash the face `mode-line-active'.
(setq flash-face-faces '(mode-line-active))
;; Customize the attributes to stay consistent with the theme.
(setq flash-face-attributes `(:background ,(catppuccin-color 'red) :foreground ,(catppuccin-color 'text)))

(provide 'init-bell)
;;; init-bell.el ends here
