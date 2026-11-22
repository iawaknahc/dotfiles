;;; init-menu-bar-mode.el --- init-menu-bar-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'menu-bar
  ;; The menu bar grows too wide.
  (menu-bar-mode -1))

(provide 'init-menu-bar-mode)
;;; init-menu-bar-mode.el ends here
