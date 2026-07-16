;;; init-ui.el --- init-ui.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

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
  :height 130)
 (set-face-attribute
  'variable-pitch
  nil
  :family "Source Han Sans"
  :weight 'normal
  :height 160)
 (setq list-faces-sample-text "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 你好世界 こんにちは 😀"))

(provide 'init-ui)
;;; init-ui.el ends here
