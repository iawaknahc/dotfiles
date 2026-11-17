;;; init-scroll-bar-mode.el --- init-scroll-bar-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'scroll-bar
  ;; The scroll bar of NS build on macOS has a light background by default.
  ;; To switch to a dark background, add (ns-transparent-titlebar . t) and
  ;; (ns-appearance . dark) to `default-frame-alist'.
  ;;
  ;; Unlike other native macOS applications where the scroll bar is only visible while scrolling,
  ;; the scroll bar is always visible.
  ;; It is particular visually annoying when there are two horizontal windows.
  ;; I want to hide it.
  (set-scroll-bar-mode nil))

(provide 'init-scroll-bar-mode)
;;; init-scroll-bar-mode.el ends here
