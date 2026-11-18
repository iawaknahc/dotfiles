;;; init-show-paren.el --- init-show-paren.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; This color is the "Surface 0" of Catppuccin Mocha.
;; We make it inherit from region (the face used by region) to ensure syntax highlighting is preserved.
(custom-set-faces
 '(show-paren-match-expression ((t (:background "#313244" :extend unspecified :inherit region)))))

(setq
 show-paren-delay 0
 show-paren-context-when-offscreen t
 show-paren-highlight-openparen t
 ;; Highlight parenthesis only for non-Lisp languages.
 show-paren-style 'parenthesis
 show-paren-when-point-in-periphery t
 show-paren-when-point-inside-paren t)
;; But for Lisp languages, highlight the whole expression because there are too many parenthesis.
(add-hook 'lisp-data-mode-hook (lambda () (setq-local show-paren-style 'expression)))

(provide 'init-show-paren)
;;; init-show-paren.el ends here
