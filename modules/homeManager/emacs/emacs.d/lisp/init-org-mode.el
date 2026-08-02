;;; init-org-mode.el --- init-org-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; To work around a very annoying bug.
 ;; 1. It is in org-mode.
 ;; 2. It is in a src block of emacs-lisp.
 ;; 3. electric-indent-mode is t.
 ;; 4. tab-always-indent is t.
 ;; 5. Type RET
 ;; 6. Nothing happens.
 org-src-tab-acts-natively nil
 ;; Change the indentation added by C-c ' to 0.
 org-src-content-indentation 0
 ;; Do not conceal links.
 org-link-descriptive nil
 ;; Org-mode timestamp format cannot be customized.
 ;; Attempt to modify `org-timestamp-formats' will cause Org-mode unable to parse the timestamp correctly.
 ;; Therefore, we work around by using `org-timestamp-custom-formats'.
 org-timestamp-custom-formats '("%G-W%V-%u" . "%G-W%V-%u %H:%M"))

;; Make sure Org-mode only read and write in ~/org
(setq
 org-directory "~/org"
 org-default-notes-file "~/org/inbox.org"
 org-attach-id-dir "~/org/attachments/"
 org-agenda-files (list "~/org/"))

(keymap-global-set "C-c c" #'org-capture)
;; The default "C-c C-x C-t" is too long.
(keymap-set org-mode-map "C-c t" #'org-toggle-timestamp-overlays)

(provide 'init-org-mode)
;;; init-org-mode.el ends here
