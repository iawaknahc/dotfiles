;;; init-input-method.el --- init-input-method.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/input-method-switch-to-english ()
  "Switch input method to English."
  (make-process
   :name "macism"
   :command (list "macism" "com.apple.keylayout.ABC")
   :buffer nil
   :noquery t)
  nil)

(add-hook 'evil-insert-state-exit-hook #'my/input-method-switch-to-english)

(provide 'init-input-method)
;;; init-input-method.el ends here
