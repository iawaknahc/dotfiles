;;; init-scroll-bar-mode.el --- init-scroll-bar-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'scroll-bar
  ;; The scroll bar of PGTK build on macOS has a white background.
  ;; I have no idea how to configure it.
  ;; So just hide it.
  (set-scroll-bar-mode nil))

(provide 'init-scroll-bar-mode)
;;; init-scroll-bar-mode.el ends here
