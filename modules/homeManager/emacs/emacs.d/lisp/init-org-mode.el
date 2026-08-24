;;; init-org-mode.el --- init-org-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


;; Make sure Org-mode only read and write in ~/org
(setq
 org-directory "~/org"
 org-default-notes-file "~/org/inbox.org"
 org-attach-id-dir "~/org/attachments/"
 org-agenda-files (list "~/org/"))


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
:CREATED: %<[%Y-%m-%d %a %H:%M]>
:END:"
 :clock-in t
 :clock-resume t)


;; Refile
(setq
 ;; `org-agenda-files' is set to include all Org files.
 ;; We of course want to refile to any Org files.
 org-refile-targets '((org-agenda-files . t))
 ;; Setting to file means the candidate in the Refile interface looks like
 ;; "file.org/heading1/heading2/heading3".
 ;; Having the filename allows me to fuzzy search using Orderless.
 org-refile-use-outline-path 'file
 ;; Setting this to nil means populate the Refile interface
 ;; with all target headlines at once.
 ;; This is useful because we are using Orderless.
 ;; Typically we type something like "filename partial-heading1 partial-heading2" to locate the target.
 org-outline-path-complete-in-steps nil)

(defun my/org-refile-datetree ()
  "Refile the level 4 headline at point to a target file.

The level 4 headline must be within a subtree.
The target files are populated from function `org-agenda-files'."
  (interactive)
  (cl-block nil
    (let* (parent-level heading decode-time-value target-file)
      (save-excursion
        (setq parent-level (org-up-heading-safe)))
      (unless (equal parent-level 3)
        (cl-return (message "This command must be invoked in a level 4 headline")))
      (save-excursion
        (org-up-heading-safe)
        (setq heading (org-get-heading 'no-tags 'no-todo 'no-priority 'no-comment)))
      ;; Extract the ISO8601 string.
      (setq heading (substring heading 0 10))
      (setq decode-time-value (iso8601-parse-date heading))
      ;; Prompt for a target file.
      (setq target-file (completing-read "Select a target file: " (org-agenda-files)))
      ;; Cut the subtree.
      (org-back-to-heading 'invisible-ok)
      (org-cut-subtree)
      ;; Create the datetree and paste the subtree.
      (with-current-buffer (find-file-noselect target-file)
        (let ((widen-the-buffer nil))
          (org-datetree-find-date-create (org-date-to-gregorian decode-time-value) widen-the-buffer))
        (org-end-of-subtree 'invisible-ok 'to-heading)
        (org-paste-subtree 4)
        (save-buffer)
        (message "Refiled the headline to %s" (buffer-name))))))


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
