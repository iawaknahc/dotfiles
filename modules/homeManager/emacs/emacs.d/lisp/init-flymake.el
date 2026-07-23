;;; init-flymake.el --- init-flymake.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-hook 'prog-mode-hook #'flymake-mode)
(add-hook 'text-mode-hook #'flymake-mode)

(setq
 ;; Use margin instead of fringe.
 flymake-indicator-type 'margins
 ;; This variable is for flymake-margin-indicators-string.
 ;; It does not consider existing things in the margin.
 flymake-autoresize-margins nil
 ;; Use initials to represent levels.
 flymake-margin-indicators-string
 '((error "E" compilation-error)
   (warning "W" compilation-warning)
   (note "I" compilation-info))
 ;; Do not wrap around.
 flymake-wrap-around nil
 ;; Always show 3 counts.
 flymake-suppress-zero-counters nil
 ;; The end-of-line message will get wrapped, making the buffer
 ;; keep flickering during editing.
 flymake-show-diagnostics-at-end-of-line nil)

(defun my/flymake-diagnostic-text (diag &optional _ignored)
  "Override `flymake-diagnostic-text'.
Note that `flymake-diagnostic-format-alist' is ignored.
Turn DIAG into text.
Note that this function is used in many places, for example,
ElDoc, end-of-line, tabulated list.
In these contexts, the level and the line are shown already.
So the text only contains the origin (or the backend), the code (optional), and the message."
  (let* ((origin (flymake-diagnostic-origin diag))
         (code (flymake-diagnostic-code diag))
         (msg (flymake-diagnostic-message diag))
         (backend (flymake-diagnostic-backend diag)))
    (cond ((and origin code) (format "(%s)(%s) %s" origin code msg))
          (origin (format "(%s) %s" origin msg))
          (code (format "(%s)(%s) %s" backend code msg))
          (t (format "(%s) %s" backend msg)))))
(advice-add 'flymake-diagnostic-text :override #'my/flymake-diagnostic-text)

(provide 'init-flymake)
;;; init-flymake.el ends here
