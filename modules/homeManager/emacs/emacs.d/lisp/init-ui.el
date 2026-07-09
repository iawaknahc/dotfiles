;;; -*- lexical-binding: t -*-

(setq inhibit-startup-screen t)
(set-frame-font "JetBrainsMonoNL Nerd Font Mono 13")
(menu-bar-mode -1)

(when (display-graphic-p)
  (tool-bar-mode -1))

(provide 'init-ui)
