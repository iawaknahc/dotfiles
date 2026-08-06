;;; init-lisp-interaction-mode.el --- init-lisp-interaction-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/eval-print-last-sexp ()
  "Replace `eval-print-last-sexp' with `pp-eval-last-sexp'."
  (interactive)
  (pp-eval-last-sexp t))

(with-eval-after-load 'elisp-mode
  (keymap-set lisp-interaction-mode-map "<remap> <eval-print-last-sexp>" #'my/eval-print-last-sexp))

(provide 'init-lisp-interaction-mode)
;;; init-lisp-interaction-mode.el ends here
