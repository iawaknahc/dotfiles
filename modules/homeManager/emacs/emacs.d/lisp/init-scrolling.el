;;; -*- lexical-binding: t -*-

(use-package
 ultra-scroll
 :ensure nil
 :custom
  ;; ultra-scroll suggests setting scroll-conservatively to 101.
 (scroll-conservatively 101)
  ;; ultra-scroll says scroll-margin must be 0 for it to work.
 (scroll-margin 0)
  ;; Enable smooth scrolling with C-v and M-v.
  ;; We have to remap C-v and M-v to pixel-scroll-interpolate-up and pixel-scroll-interpolate-down.
 (pixel-scroll-precision-interpolate-page t)
 (pixel-scroll-precision-interpolation-total-time 0.2)
 :config
 (ultra-scroll-mode 1)
 :bind (([remap scroll-up-command] . pixel-scroll-interpolate-down)
        ([remap scroll-down-command] . pixel-scroll-interpolate-up)))

(provide 'init-scrolling)
