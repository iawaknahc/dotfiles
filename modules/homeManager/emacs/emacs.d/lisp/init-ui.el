;;; -*- lexical-binding: t -*-

(setq inhibit-startup-screen t)

(menu-bar-mode -1)
(when (display-graphic-p)
  (tool-bar-mode -1))

(set-face-attribute
 'default
 nil
 :family "JetBrainsMonoNL Nerd Font Mono"
 :weight 'light
 :height 130)

(provide 'init-ui)
