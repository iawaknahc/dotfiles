;;; init-hyperbole.el --- init-hyperbole.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; The only feature I need from Hyperbole is implicit button.
;; Embark already handles URLs, files, and many more.
;; I just need to invoke `embark-dwim'.
;; If I need URLs to be highlighted, I can use the built-in `goto-address-mode'.
;; URLs in `org-mode' are highlighted though.
;;
;; A bigger problem is Hyperbole messed up my `display-buffer-alist' configuration.
;; It set `temp-buffer-show-function' to `hkey-help-show'.
;; `hkey-help-show' uses `hpath:display-where' to determine how to display buffer.
;; I do not like this because it introduces its own system of displaying buffer,
;; while there is a standard `display-buffer' framework.
;;
;; Therefore, I uninstalled GNU Hyperbole.
;;
;;; Code:

(provide 'init-hyperbole)
;;; init-hyperbole.el ends here
