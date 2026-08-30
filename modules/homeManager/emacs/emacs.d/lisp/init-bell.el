;;; init-bell.el --- init-bell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; On PGTK build, the visible bell is a large image displayed at the center of the screen.
 ;; This is too annoying.
 visible-bell nil
 ;; Flashing some faces to indicate a bell.
 ring-bell-function #'flash-face-bell-function
 ;; Flash the face `mode-line-active'.
 flash-face-faces '(mode-line-active)
 ;; Customize the attributes to stay consistent with the theme.
 flash-face-attributes `(:background ,(catppuccin-color 'red) :foreground ,(catppuccin-color 'text)))

(provide 'init-bell)
;;; init-bell.el ends here
