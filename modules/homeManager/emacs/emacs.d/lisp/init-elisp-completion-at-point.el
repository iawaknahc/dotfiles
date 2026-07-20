;;; init-elisp-completion-at-point.el --- init-elisp-completion-at-point.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/elisp-completion-at-point-annotation-function (candidate)
  "Annotation function for `elisp-completion-at-point'.
CANDIDATE is used as usual."
  (when-let* ((sym (intern-soft candidate)))
    (marginalia--fields
     ((get-text-property 0 'help-echo (marginalia--symbol-class sym)) :face 'marginalia-type))))

(defun my/elisp-completion-at-point-around (capf)
  "Wrap CAPF :annotation-function."
  (cape-wrap-properties capf :annotation-function #'my/elisp-completion-at-point-annotation-function))

(advice-add 'elisp-completion-at-point :around #'my/elisp-completion-at-point-around)

(provide 'init-elisp-completion-at-point)
;;; init-elisp-completion-at-point.el ends here
