;;; -*- lexical-binding: t -*-

(defun my/elisp-completion-at-point-annotation-function (candidate)
  (when-let* ((sym (intern-soft candidate)))
             (marginalia--fields
              ((get-text-property 0 'help-echo (marginalia--symbol-class sym)) :face 'marginalia-type))))

(defun my/elisp-completion-at-point-around (capf)
  "Wrap CAPF :annotation-function"
  (cape-wrap-properties capf :annotation-function #'my/elisp-completion-at-point-annotation-function))

(use-package
 emacs
 :after (cape marginalia)
 :config
 (advice-add 'elisp-completion-at-point :around #'my/elisp-completion-at-point-around))

(provide 'init-elisp-completion-at-point)
