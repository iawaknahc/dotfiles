;;; init-theme.el --- init-theme.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 emacs
 :init
 (load-theme 'catppuccin :no-confirm)
 (setq catppuccin-flavor 'mocha)
 (setq catppuccin-italic-comments t)
 (catppuccin-reload))

(provide 'init-theme)
;;; init-theme.el ends here
