;;; init-flymake-quickdef.el --- init-flymake-quickdef.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'flymake-quickdef)

(flymake-quickdef-backend
  flymake-codespell
  "Flymake backend for codespell."
  :pre-let ((codespell-exec (executable-find "codespell")))
  :pre-check (unless codespell-exec (error "The command codespell not found in PATH"))
  :write-type 'pipe
  :proc-form (list codespell-exec "--stdin-single-line" "-")
  :search-regexp (rx line-start (group-n 1 (+ digit)) ": " (group-n 2 (* not-newline)) line-end)
  :prep-diagnostic
  (let* ((lnum (string-to-number (match-string 1)))
         (pos (flymake-diag-region fmqd-source lnum))
         (beg (car pos))
         (end (cdr pos))
         (type :error)
         (msg (match-string 2)))
    (list fmqd-source beg end type (list "codespell" nil msg))))

(flymake-quickdef-backend
  flymake-hadolint
  "Flymake backend for Hadolint."
  :pre-let ((hadolint-exec (executable-find "hadolint")))
  :pre-check (unless hadolint-exec (error "The command hadolint not found in PATH"))
  :write-type 'pipe
  :proc-form (list hadolint-exec "--format" "tty" "--no-color" "-")
  :search-regexp
  (rx
   line-start
   "-:"
   (group-n 1 (+ digit))
   " "
   (group-n 2 (seq (>= 2 (in "A-Z")) (>= 4 digit)))
   " "
   (group-n 3 (| "error" "warning" "info" "style"))
   ": "
   (group-n 4 (* not-newline))
   line-end)
  :prep-diagnostic
  (let* ((lnum (string-to-number (match-string 1)))
         (pos (flymake-diag-region fmqd-source lnum))
         (beg (car pos))
         (end (cdr pos))
         (code (match-string 2))
         (level (match-string 3))
         (type (pcase level
                 ("error" :error)
                 ("warning" :warning)
                 ("info" :note)
                 ("style" :note)
                 (_ :error)))
         (msg (match-string 4)))
    (list fmqd-source beg end type (list "hadolint" code msg))))

(defun my/flymake-add-all-custom-backends ()
  "Add all custom backends to `flymake-diagnostic-functions'."
  (add-hook 'flymake-diagnostic-functions #'flymake-codespell nil t))

(add-hook 'prog-mode-hook #'my/flymake-add-all-custom-backends)
(add-hook 'text-mode-hook #'my/flymake-add-all-custom-backends)

(add-hook
 'dockerfile-ts-mode-hook
 (lambda ()
   (add-hook 'flymake-diagnostic-functions #'flymake-hadolint nil t)))

(provide 'init-flymake-quickdef)
;;; init-flymake-quickdef.el ends here
