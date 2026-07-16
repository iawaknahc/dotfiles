;;; init-show-paren.el --- init-show-paren.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 emacs
 :custom-face
 ;; This color is the "Surface 0" of Catppuccin Mocha.
 ;; We make it inherit from region (the face used by region) to ensure syntax highlighting is preserved.
 (show-paren-match-expression ((t (:background "#313244" :extend unspecified :inherit region))))
 :custom
 (show-paren-delay 0)
 (show-paren-context-when-offscreen t)
 (show-paren-highlight-openparen t)
 (show-paren-style 'expression)
 (show-paren-when-point-in-periphery t)
 (show-paren-when-point-inside-paren t))

(provide 'init-show-paren)
;;; init-show-paren.el ends here
