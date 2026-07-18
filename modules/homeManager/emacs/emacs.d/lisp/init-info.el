;;; init-info.el --- init-info.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/info-apropos (string)
  "Like `info-apropos', but defaults to the symbol at point."
  (interactive
   (let ((sym (thing-at-point 'symbol t)))
     (list (read-string (format-prompt "Info apropos" sym) nil nil sym))))
  (info-apropos string))

(use-package
 info
 :ensure nil
 :bind (("C-c i" . #'my/info-apropos)))

(provide 'init-info)
;;; init-info.el ends here
