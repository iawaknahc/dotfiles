;;; -*- lexical-binding: t -*-

(use-package
 emacs
 :ensure nil
 :custom
 (inhibit-startup-screen t)
 :config
 (menu-bar-mode -1)
 (when (display-graphic-p)
   (tool-bar-mode -1))
 (set-face-attribute
  'default
  nil
  :family "JetBrainsMonoNL Nerd Font Mono"
  :weight 'light
  :height 130))

(provide 'init-ui)
