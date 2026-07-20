;;; init-compilation-mode.el --- init-compilation-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; Add an advice to `compilation-goto-locus' so that
;; the buffer is always shown in the other window.
;; By default, sometimes the other window is used, sometimes a new window is created.
;; This is too unpredictable.
;; Note that `compilation-goto-locus' is the ultimate function that calls `display-buffer'.
;; Modes such `grep-mode', which is derived from `compilation-mode', can also benefit from this change.
;;
;;; Code:

(defun my/compilation-goto-locus (f &rest args)
  "An :around advice of `compilation-goto-locus'.
Apply F with ARGS."
  (let ((display-buffer-overriding-action
         '((display-buffer-reuse-window display-buffer-use-some-window))))
    (apply f args)))
(advice-add 'compilation-goto-locus :around #'my/compilation-goto-locus)

(provide 'init-compilation-mode)
;;; init-compilation-mode.el ends here
