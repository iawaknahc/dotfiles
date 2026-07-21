;;; init-flymake-quickdef.el --- init-flymake-quickdef.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'flymake-quickdef)

(flymake-quickdef-backend
  flymake-codespell
  "Flymake backend for codespell."
  :pre-let ((codespell-exec (executable-find "codespell")))
  :pre-check (unless codespell-exec (error "Cannot find executable codespell"))
  :write-type 'pipe
  :proc-form (list codespell-exec "--stdin-single-line" "-")
  :search-regexp (rx line-start (group-n 1 (+ (in "0123456789"))) ": " (group-n 2 (* not-newline)) line-end)
  :prep-diagnostic
  (let* ((lnum (string-to-number (match-string 1)))
         (pos (flymake-diag-region fmqd-source lnum))
         (beg (car pos))
         (end (cdr pos))
         (type :error)
         (info (match-string 2)))
    (list fmqd-source beg end type info)))

(defun my/flymake-add-all-custom-backends ()
  "Add all custom backends to `flymake-diagnostic-functions'."
  (add-hook 'flymake-diagnostic-functions #'flymake-codespell nil t))

(add-hook 'prog-mode-hook #'my/flymake-add-all-custom-backends)
(add-hook 'text-mode-hook #'my/flymake-add-all-custom-backends)

(provide 'init-flymake-quickdef)
;;; init-flymake-quickdef.el ends here
