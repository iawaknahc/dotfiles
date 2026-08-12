;;; init-scrolling.el --- init-scrolling.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'scroll-bar
  ;; The scroll bar of PGTK build on macOS has a white background.
  ;; I have no idea how to configure it.
  ;; So just hide it.
  (set-scroll-bar-mode nil))

(provide 'init-scrolling)
;;; init-scrolling.el ends here
