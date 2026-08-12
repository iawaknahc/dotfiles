;;; init-bell.el --- init-bell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; TODO: Re-visit this when Emacs is upgraded to 31.1.
;; See https://github.com/emacs-mirror/emacs/blob/master/lisp/ring-bell-fns.el
(setq
 ;; On PGTK build, the visible bell is a large image displayed at the center of the screen.
 ;; This is too annoying.
 visible-bell nil
 ;; So disable the bell by setting `ring-bell-function' to `ignore'.
 ring-bell-function #'ignore)

(provide 'init-bell)
;;; init-bell.el ends here
