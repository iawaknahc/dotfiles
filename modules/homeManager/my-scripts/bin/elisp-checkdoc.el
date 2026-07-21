#!/usr/bin/env -S emacs --quick --script

(require 'checkdoc)

(defvar my/checkdoc-had-warnings nil)

;; Override `display-warning' so that we have full control on
;; how the output look like.
(advice-add
 'display-warning :override
 (lambda (type message &rest _)
   (setq my/checkdoc-had-warnings t)
   (princ (format "%s\n" (string-trim message)))))

(defun my/checkdoc-file (file)
  (let ((checkdoc-diagnostic-buffer "*checkdoc-batch*"))
    (with-current-buffer (get-buffer-create checkdoc-diagnostic-buffer)
      (erase-buffer))
    (checkdoc-file file)))

(unless argv
  (message "Usage: elisp-checkdoc.el FILE.el [FILE2.el ...]")
  (kill-emacs 1))

(dolist (file argv)
  (my/checkdoc-file file))

(kill-emacs (if my/checkdoc-had-warnings 1 0))
