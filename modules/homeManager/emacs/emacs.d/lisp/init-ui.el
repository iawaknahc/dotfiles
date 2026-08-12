;;; init-ui.el --- init-ui.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(menu-bar-mode -1)
(when (display-graphic-p)
  (tool-bar-mode -1))

(setq inhibit-startup-screen t)

(provide 'init-ui)
;;; init-ui.el ends here
