;;; init-org-mode.el --- init-org-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


;; Make sure Org-mode only read and write in ~/org
(setq
 org-directory "~/org"
 org-default-notes-file "~/org/inbox.org"
 org-attach-id-dir "~/org/attachments/")


;; Source blocks
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
 org-src-content-indentation 0)


;; Startup visibility
(setq
 ;; This is equivalent to having =#+startup: content= in every file.
 ;; This is particularly useful since every file now has a top-level properties drawer
 ;; containing an ID property.
 org-startup-folded 'content
 ;; Hide blocks.
 org-hide-block-startup t)


;; Timestamps
(setq
 ;; Org-mode timestamp format cannot be customized.
 ;; Attempt to modify `org-timestamp-formats' will cause Org-mode unable to parse the timestamp correctly.
 ;; Therefore, we work around by using `org-timestamp-custom-formats'.
 org-timestamp-custom-formats '("%G-W%V-%u" . "%G-W%V-%u %H:%M")
 ;; Increment minute by 5 minutes. This is the default.
 org-timestamp-rounding-minutes '(0 5))


;; Links and IDs
(setq
 ;; Do not conceal links.
 org-link-descriptive nil
 ;; Use `org-id-ts-format' to generate ID.
 org-id-method 'ts
 ;; When prefix is non-nil,
 ;; The generated ID is PREFIX : GENERATED
 ;; That is, a colon is always added between the prefix and the generated part.
 ;; This is not documented in `org-id-prefix',
 ;; but documented in the example given in `org-id-new'.
 ;; I do not like this behavior, so just leave `org-id-prefix' as nil, which is also the default.
 org-id-prefix nil
 ;; Make `org-store-link' create an ID.
 ;; This is barely useful because we want to be able to fuzzy search any headlines in any files, and
 ;; generate an ID in-just-time, and finally insert the link to that ID.
 ;; The built-in pcomplete "[[*" of Org does not support this.
 ;; It merely inserts the search-based link in the same file.
 org-id-link-to-org-use-id 'create-if-interactive
 ;; Instead of using `org-id-prefix' to add prefix,
 ;; we embed the prefix in `org-id-ts-format'.
 org-id-ts-format "org_%Y%m%d_%H%M%S_%N")


;; TODO and clock
(setq
 ;; Log timestamp when a TODO is DONE.
 org-log-done 'time
 ;; Only save the running clock.
 ;; `org-clock-persistence-insinuate' must be called in order to make this effective.
 org-clock-persist 'clock
 ;; Update the clock mode line string every 20 seconds.
 org-clock-update-period 20
 ;; Clock out when the task is marked DONE.
 ;; The default is t.
 org-clock-out-when-done t
 ;; Do not switch state when clocking out.
 ;; When a capture template has :clock-in and :clock-resume,
 ;; the time spent on creating the capture is clocked.
 ;; When the capture is a TODO item,
 ;; we want to track the time we spent on creating the capture,
 ;; but definitely do not want to mark the TODO item as DONE.
 org-clock-out-switch-to-state nil
 ;; On macOS PGTK build, frame-title-format is buggy.
 ;; Here are the steps to reproduce the bug:
 ;; 1. Clock in
 ;; 2. See the frame title show the clock correctly.
 ;; 3. Switch to another tab-bar-mode tab.
 ;; 4. See the frame title does not show the clock.
 ;;
 ;; Even running `force-mode-line-update' in the tab does not help.
 org-clock-clocked-in-display 'both)
;; This function must be called.
;; Otherwise, `org-clock-persist' has no effect.
(org-clock-persistence-insinuate)


(keymap-global-set "C-c a" #'org-agenda)
(keymap-global-set "C-c l" #'org-store-link)
(keymap-global-set "C-c c" #'org-capture)
(keymap-global-set "C-c C" #'org-capture-goto-last-stored)
(with-eval-after-load 'org
  ;; The default "C-c C-x C-t" is too long.
  (keymap-set org-mode-map "C-c t" #'org-toggle-timestamp-overlays)
  (keymap-set org-mode-map "C-c C-x <control-i>" #'org-clock-in))


;; Agenda
(defun my/org-agenda-before--set-org-agenda-files (&rest _args)
  "Set the variable `org-agenda-files'.

Only Project or Area file-level notes are targets of agenda."
  (let* ((file-notes (vulpea-db-query (lambda (note)
                                        (let* ((tags (vulpea-note-tags note))
                                               (level (vulpea-note-level note)))
                                          (and (equal 0 level)
                                               (or (seq-contains-p tags "project")
                                                   (seq-contains-p tags "area")))))))
         (filepaths (seq-map #'vulpea-note-path file-notes)))
    (setq org-agenda-files filepaths)))
;; Just-in-time set variable `org-agenda-files' before `org-agenda' runs.
(advice-add #'org-agenda :before #'my/org-agenda-before--set-org-agenda-files)

(setq
 org-agenda-custom-commands
 `(("a" "General agenda" agenda ""
    ((org-agenda-skip-function
      '(let* ((tags (org-get-tags)))
         (when (or (seq-contains-p tags "life")
                   (seq-contains-p tags "worklog"))
           (point))))))
   ("A" "All agenda" agenda "")
   ("w" "Worklog entries" agenda ""
    ((org-agenda-files (list "~/org/worklog.org"))
     (org-agenda-skip-function
      '(let* ((tags (org-get-tags)))
         (unless (seq-contains-p tags "worklog")
           (point))))))
   ("y" "Yearly agenda of services" agenda ""
    ((org-agenda-span ,(* 7 53))
     (org-agenda-show-all-dates nil)
     (org-agenda-skip-function
      '(let* ((tags (org-get-tags)))
         (unless (seq-contains-p tags "service")
           (point))))))))


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


;; Capture
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
 :description "Create a vulpea-compatible heading-level note and clock the time spent on creating it"
 :type 'entry
 :target '(file "~/org/inbox.org")
 :template "TODO %?
:PROPERTIES:
:ID:      %(org-id-new)
:CREATED: %<<%Y-%m-%d %a %H:%M>>
:END:"
 :clock-in t
 :clock-resume t)


;; Refile
(defun my/org-refile-targets-with-vulpea ()
  "Return a list of filepaths suitable for `org-refile-targets'."
  (let* ((file-notes (vulpea-db-query (lambda (note)
                                        (let* ((level (vulpea-note-level note)))
                                          (equal 0 level)))))
         (filepaths (seq-map #'vulpea-note-path file-notes)))
    filepaths))

(setq
 ;; All file-level notes are refile targets.
 org-refile-targets '((my/org-refile-targets-with-vulpea . t))
 ;; Setting to file means the candidate in the Refile interface looks like
 ;; "file.org/heading1/heading2/heading3".
 ;; Having the filename allows me to fuzzy search using Orderless.
 org-refile-use-outline-path 'file
 ;; Setting this to nil means populate the Refile interface
 ;; with all target headlines at once.
 ;; This is useful because we are using Orderless.
 ;; Typically we type something like "filename partial-heading1 partial-heading2" to locate the target.
 org-outline-path-complete-in-steps nil)


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
