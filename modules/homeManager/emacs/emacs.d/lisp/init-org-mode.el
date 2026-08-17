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
 org-timestamp-custom-formats '("%G-W%V-%u" . "%G-W%V-%u %H:%M")
 ;; Increment minute by 5 minutes. This is the default.
 org-timestamp-rounding-minutes '(0 5))


;; Make sure Org-mode only read and write in ~/org
(setq
 org-directory "~/org"
 org-default-notes-file "~/org/inbox.org"
 org-attach-id-dir "~/org/attachments/"
 org-agenda-files (list "~/org/"))


;; TODO and clock
(setq
 ;; Log timestamp when a TODO is DONE.
 org-log-done 'time
 ;; Only save the running clock.
 org-clock-persist 'clock
 ;; Update the clock mode line string every 20 seconds.
 org-clock-update-period 20
 ;; Clock out when the task is marked DONE.
 ;; The default is t.
 org-clock-out-when-done t
 ;; Or, mark DONE when clock out.
 ;; The default is nil.
 ;; I have no idea why the default does not match `org-clock-out-when-done'.
 org-clock-out-switch-to-state "DONE"
 ;; Reserve the frame title solely for clock.
 frame-title-format
 `(:eval (progn
           (require 'org-clock)
           (if (org-clocking-p)
               org-mode-line-string
             "No clock is running"))))

(keymap-global-set "C-c a" #'org-agenda)
(keymap-global-set "C-c l" #'org-store-link)
(keymap-global-set "C-c c" #'org-capture)
(with-eval-after-load 'org
  ;; The default "C-c C-x C-t" is too long.
  (keymap-set org-mode-map "C-c t" #'org-toggle-timestamp-overlays)
  (keymap-set org-mode-map "C-c C-x <control-i>" #'org-clock-in))


;; Agenda
(setq
 org-agenda-custom-commands
 `(("a" "General agenda" agenda ""
    ((org-agenda-skip-function
      '(when (member "life" (org-get-tags))
         (point)))))
   ("A" "All agenda" agenda "")
   ("y" "Yearly agenda of services" agenda ""
    ((org-agenda-span ,(* 7 53))
     (org-agenda-show-all-dates nil)
     (org-agenda-skip-function
      '(when (not (member "service" (org-get-tags)))
         (point)))))))

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


(cl-defun my/org-add-capture-template
    (&rest args &key key description type target template &allow-other-keys)
  "A helper to add capture template.
ARGS, KEY, DESCRIPTION, TYPE, TARGET, TEMPLATE, PROPERTIES are interpreted according to the manual."
  (let* ((rest (copy-sequence args)))
    (cl-remf rest :key)
    (cl-remf rest :description)
    (cl-remf rest :type)
    (cl-remf rest :target)
    (cl-remf rest :template)
    (add-to-list 'org-capture-templates `(,key ,description ,type ,target ,template ,@rest))))

;; Set `org-capture-templates' to nil to ensure it exists.
(setq org-capture-templates nil)
(my/org-add-capture-template
 :key "t"
 :description "Create a new task and clock in"
 :type 'entry
 :target '(file+olp+datetree "~/org/worklog.org")
 :template "TODO %?
%U"
 :clock-in t
 :clock-keep t)


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

;; Add a command to insert datetree.
(defun my/org-datetree-insert ()
  "Insert datetree into current buffer."
  (interactive)
  (let* ((widen-the-buffer nil)
         (org-date (org-read-date))
         (greg-date (org-date-to-gregorian org-date)))
    (org-datetree-find-date-create greg-date widen-the-buffer)))

(provide 'init-org-mode)
;;; init-org-mode.el ends here
