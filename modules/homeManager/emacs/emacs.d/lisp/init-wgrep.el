;;; init-wgrep.el --- init-wgrep.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; In Emacs 31, grep-edit-mode is available and this package may be unnecessary.
;;
;; A workflow of this is like:
;; 1. M-x grep and then type in the search query.
;; 2. A grep-mode buffer pops up.
;; 3. Press e in the grep-mode buffer to switch to wgrep.
;; 4. In wgrep, M-x replace-regexp.
;;    The pain point is, we have to repeat the query in Emacs regexp syntax.
;; 5. Type C-c C-c to save changes.
;;
;; It may be tempting to use `project-query-replace-regexp'.
;; But it is bad in many ways.
;; It open each file as buffer, polluting my Emacs session.
;; It does not save the buffers right away.
;;
;;; Code:

(with-eval-after-load 'grep
  (setq
   ;; This is the key binding of grep-edit-mode in Emacs 31.
   wgrep-enable-key "e"
   ;; Save changes when C-c C-c is typed.
   wgrep-auto-save-buffer t)
  (require 'wgrep))

(provide 'init-wgrep)
;;; init-wgrep.el ends here
