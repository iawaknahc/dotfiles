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
(with-eval-after-load 'org
  ;; The default "C-c C-x C-t" is too long.
  (keymap-set org-mode-map "C-c t" #'org-toggle-timestamp-overlays))

(defun my/org-ctrl-c-ctrl-c-column-view ()
  "Turn on column view when we are at the buffer global COLUMNS property line.
When column view is on, \\[org-ctrl-c-ctrl-c] already turns it off.
And in fact, it has a higher priority than us."
  (when (save-excursion
          (beginning-of-line)
          (looking-at-p (rx line-start "#+COLUMNS: ")))
    ;; `org-columns-overlays' is unbound until the first time `org-columns' is called.
    (unless (and (boundp 'org-columns-overlays) org-columns-overlays)
      (org-columns)
      t)))
(add-hook 'org-ctrl-c-ctrl-c-hook #'my/org-ctrl-c-ctrl-c-column-view)

;; Integrate `org-lint' with `flymake'.
(defun my/flymake-org-lint (report-fn &rest _args)
  "A flymake backend for `org-lint'.
REPORT-FN is respected."
  (let* ((source (current-buffer))
         (reports-alist (org-lint))
         diags)
    (dolist (element reports-alist)
      (pcase-let* ((`(,id [,line ,trust ,msg ,checker]) element)
                   (`(,beg . ,end) (flymake-diag-region source (string-to-number line)))
                   (code (symbol-name (org-lint-checker-name checker)))
                   (info (list "org-lint" code msg))
                   (diag (flymake-make-diagnostic source beg end :error info)))
        (push diag diags)))
    (funcall report-fn (nreverse diags))))
(add-hook 'org-mode-hook (lambda ()
                           (add-hook 'flymake-diagnostic-functions #'my/flymake-org-lint nil t)))

(provide 'init-org-mode)
;;; init-org-mode.el ends here
