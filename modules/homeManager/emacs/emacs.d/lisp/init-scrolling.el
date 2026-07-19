;;; init-scrolling.el --- init-scrolling.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; ultra-scroll suggests setting scroll-conservatively to 101.
 scroll-conservatively 101
 ;; ultra-scroll says scroll-margin must be 0 for it to work.
 scroll-margin 0
 ;; Enable smooth scrolling with C-v and M-v.
 ;; We have to remap C-v and M-v to pixel-scroll-interpolate-up and pixel-scroll-interpolate-down.
 pixel-scroll-precision-interpolate-page t
 pixel-scroll-precision-interpolation-total-time 0.2)

(keymap-global-set "<remap> <scroll-up-command>" #'pixel-scroll-interpolate-down)
(keymap-global-set "<remap> <scroll-down-command>" #'pixel-scroll-interpolate-up)

(ultra-scroll-mode 1)

(provide 'init-scrolling)
;;; init-scrolling.el ends here
