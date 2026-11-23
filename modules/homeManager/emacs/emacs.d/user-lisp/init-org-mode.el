;;; init-org-mode.el --- init-org-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'cl-lib)

(defvar org-agenda-custom-commands)
(defvar org-agenda-files)
(defvar org-agenda-include-diary)
(defvar org-agenda-show-all-dates)
(defvar org-archive-sibling-heading)
(defvar org-attach-id-dir)
(defvar org-capture-templates)
(defvar org-clock-clocked-in-display)
(defvar org-clock-out-switch-to-state)
(defvar org-clock-out-when-done)
(defvar org-clock-persist)
(defvar org-clock-update-period)
(defvar org-default-notes-file)
(defvar org-directory)
(defvar org-format-latex-options)
(defvar org-hide-block-startup)
(defvar org-id-link-to-org-use-id)
(defvar org-id-method)
(defvar org-id-prefix)
(defvar org-id-ts-format)
(defvar org-link-descriptive)
(defvar org-log-done)
(defvar org-mode-map)
(defvar org-outline-path-complete-in-steps)
(defvar org-preview-latex-default-process)
(defvar org-refile-targets)
(defvar org-refile-use-outline-path)
(defvar org-src-content-indentation)
(defvar org-src-tab-acts-natively)
(defvar org-startup-folded)
(defvar org-timestamp-custom-formats)
(defvar org-timestamp-rounding-minutes)
(declare-function diary-mark-entries "diary-lib")
(declare-function diary-view-entries "diary-lib")
(declare-function my/org-agenda-optimize--around "my-org")
(declare-function my/org-calendar-holiday--around "my-org")
(declare-function my/org-calendar-holiday--invalidate "my-org")
(declare-function org-agenda-redo "org-agenda")
(declare-function org-calendar-holiday "org")
(declare-function org-capture-goto-last-stored "org-capture")
(declare-function org-clock-in "org-clock")
(declare-function org-columns "org-colview")
(declare-function org-datetree-find-date-create "org-datetree")
(declare-function org-element-property "org-element-ast" t t)
(declare-function org-entry-get "org")
(declare-function org-find-olp "org")
(declare-function org-get-heading "org")
(declare-function org-lint "org-lint")
(declare-function org-lint-checker-name "org-lint" t t)
(declare-function org-map-entries "org")
(declare-function org-refile "org-refile")
(declare-function org-sort-entries "org")
(declare-function org-store-link "ol")
(declare-function org-timestamp-from-string "org")
(declare-function org-timestamp-to-time "org")
(declare-function org-today "org")
(declare-function org-toggle-timestamp-overlays "org")
(declare-function vulpea-db-query "vulpea-db-query")
(declare-function vulpea-note-level "vulpea-note" t t)
(declare-function vulpea-note-path "vulpea-note" t t)
(declare-function vulpea-note-tags "vulpea-note" t t)

;;;; Make sure Org-mode only read and write in ~/org
(setq org-directory "~/org")
(setq org-default-notes-file "~/org/inbox.org")
(setq org-attach-id-dir "~/org/attachments/")


;;;; Source blocks
;; To work around a very annoying bug.
;; 1. It is in org-mode.
;; 2. It is in a src block of emacs-lisp.
;; 3. electric-indent-mode is t.
;; 4. tab-always-indent is t.
;; 5. Type RET
;; 6. Nothing happens.
(setq org-src-tab-acts-natively nil)
;; Change the indentation added by C-c ' to 0.
(setq org-src-content-indentation 0)


;;;; Startup visibility
;; This is equivalent to having =#+startup: content= in every file.
;; This is particularly useful since every file now has a top-level properties drawer
;; containing an ID property.
(setq org-startup-folded 'content)
;; Hide blocks.
(setq org-hide-block-startup t)


;;;; Timestamps
;; Org-mode timestamp format cannot be customized.
;; Attempt to modify `org-timestamp-formats' will cause Org-mode unable to parse the timestamp correctly.
;; Therefore, we work around by using `org-timestamp-custom-formats'.
(setq org-timestamp-custom-formats '("%G-W%V-%u" . "%G-W%V-%u %H:%M"))
;; Increment minute by 5 minutes. This is the default.
(setq org-timestamp-rounding-minutes '(0 5))


;;;; Links and IDs
;; Do not conceal links.
(setq org-link-descriptive nil)
;; Use `org-id-ts-format' to generate ID.
(setq org-id-method 'ts)
;; When prefix is non-nil,
;; The generated ID is PREFIX : GENERATED
;; That is, a colon is always added between the prefix and the generated part.
;; This is not documented in `org-id-prefix',
;; but documented in the example given in `org-id-new'.
;; I do not like this behavior, so just leave `org-id-prefix' as nil, which is also the default.
(setq org-id-prefix nil)
;; Make `org-store-link' create an ID.
;; This is barely useful because we want to be able to fuzzy search any headlines in any files, and
;; generate an ID in-just-time, and finally insert the link to that ID.
;; The built-in pcomplete "[[*" of Org does not support this.
;; It merely inserts the search-based link in the same file.
(setq org-id-link-to-org-use-id 'create-if-interactive)
;; Instead of using `org-id-prefix' to add prefix,
;; we embed the prefix in `org-id-ts-format'.
(setq org-id-ts-format "org_%Y%m%d_%H%M%S_%N")


;;;; TODO and clock
;; Log timestamp when a TODO is DONE.
(setq org-log-done 'time)
;; Only save the running clock.
;; `org-clock-persistence-insinuate' must be called in order to make this effective.
(setq org-clock-persist 'clock)
;; Update the clock mode line string every 20 seconds.
(setq org-clock-update-period 20)
;; Clock out when the task is marked DONE.
;; The default is t.
(setq org-clock-out-when-done t)
;; Do not switch state when clocking out.
;; When a capture template has :clock-in and :clock-resume,
;; the time spent on creating the capture is clocked.
;; When the capture is a TODO item,
;; we want to track the time we spent on creating the capture,
;; but definitely do not want to mark the TODO item as DONE.
(setq org-clock-out-switch-to-state nil)
;; `frame-title-format' may not work as expected when
;; the following conditions hold:
;;
;; 1. It is on macOS NS build.
;; 2. A tiling window manager, like AeroSpace, is in use.
;; 3. `frame-resize-pixelwise' is nil.
;;
;; In that case, the frame title will be set unconditionally in
;; https://github.com/emacs-mirror/emacs/blob/emacs-31.1/src/nsterm.m#L8285
;; when Emacs considers itself resizing.
;;
;; Condition 1 cannot be changed.
;; Condition 2 is unlikely to be changed because I want to use tiling window manager.
;; Thus, we can only change Condition 3.
;; We just need to set `frame-resize-pixelwise' to t.
;;
;; When `frame-resize-pixelwise' set to t,
;; the symptom occurs less often.
;; It will certainly occur when we move the frame with the tiling window manager,
;; for example, moving the frame of Emacs to another AeroSpace workspace with an existing AeroSpace window.
;;
;; The symptom will correct itself when the clock ticks one more minute.
;; This observation implies if the frame title is different, it will be re-displayed.
;; If we really want a workaround, we can customize `org-clock-frame-title-format',
;; and include something that is different per invocation, like a timestamp.
;; I experimented with this and found that the frame-title-format is actually
;; evaluated more often than I thought.
;; So I left out this workaround.
(setq org-clock-clocked-in-display 'both)
;; This function must be called.
;; Otherwise, `org-clock-persist' has no effect.
(org-clock-persistence-insinuate)


;;;; Activation
(keymap-global-set "C-c a" #'org-agenda)
(keymap-global-set "C-c l" #'org-store-link)
(keymap-global-set "C-c c" #'org-capture)
(keymap-global-set "C-c C" #'org-capture-goto-last-stored)
(with-eval-after-load 'org
  ;; The default "C-c C-x C-t" is too long.
  (keymap-set org-mode-map "C-c t" #'org-toggle-timestamp-overlays)
  (keymap-set org-mode-map "C-c C-x <control-i>" #'org-clock-in))


;;;; Agenda
(defvar my/org-agenda-files-last nil
  "Last value of variable `org-agenda-files'.")

(defun my/org-agenda-before--set-org-agenda-files (&rest _args)
  "Set variable `org-agenda-files' if it is not bound already.

A custom agenda command may specify variable `org-agenda-files'
and make it bound."
  ;; If variable `org-agenda-files' is unbound, for example,
  ;; invoking the ordinary agenda.
  (when (or (null org-agenda-files)
            ;; Or the value of variable `org-agenda-files' did not change.
            (eq org-agenda-files my/org-agenda-files-last))
    (let* ((file-notes
            (vulpea-db-query
             (lambda (note)
               (let ((tags (vulpea-note-tags note))
                     (level (vulpea-note-level note)))
                 (and (equal 0 level)
                      (or (seq-contains-p tags "project")
                          (seq-contains-p tags "area")))))))
           (filepaths (seq-map #'vulpea-note-path file-notes)))
      (setq my/org-agenda-files-last filepaths)
      (setq org-agenda-files filepaths))))
;; Just-in-time set variable `org-agenda-files' before `org-agenda-list' runs.
;; The advice is added to `org-agenda-list' so that `org-agenda' and `org-calendar-goto-agenda' can benefit.
(advice-add #'org-agenda-list :before #'my/org-agenda-before--set-org-agenda-files)
(advice-add #'diary-mark-entries :before #'my/org-agenda-before--set-org-agenda-files)
(advice-add #'diary-view-entries :before #'my/org-agenda-before--set-org-agenda-files)

(setq
 ;; According to the manual
 ;; https://orgmode.org/manual/Weekly_002fdaily-agenda.html#Calendar_002fDiary-integration-1
 ;; it is faster to use `org-calendar-holiday' to show holidays in the agenda view.
 org-agenda-include-diary nil)

;; Speed up `org-calendar-holiday'
(advice-add #'org-calendar-holiday :around #'my/org-calendar-holiday--around)
(advice-add #'org-agenda-redo :before #'my/org-calendar-holiday--invalidate)

(defun my/org-agenda-toggle-show-all-dates ()
  "Toggle the global value of `org-agenda-show-all-dates' and rebuild the agenda."
  (interactive)
  (setq org-agenda-show-all-dates (not org-agenda-show-all-dates))
  (org-agenda-redo)
  (message "Show all dates: %s" (if org-agenda-show-all-dates "on" "off")))

;; Speed up `org-agenda-list'.
(advice-add #'org-agenda-list :around #'my/org-agenda-optimize--around)

;; Speed up `org-diary'.
(advice-add #'org-diary :around #'my/org-agenda-optimize--around)


;;;; Column view
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


;;;; Capture
(cl-defun my/org-capture-template
    (&rest args &key key description type target template &allow-other-keys)
  "A helper to create a capture template.
ARGS, KEY, DESCRIPTION, TYPE, TARGET, TEMPLATE, PROPERTIES are interpreted
according to the manual."
  (let* ((rest (copy-sequence args)))
    (cl-remf rest :key)
    (cl-remf rest :description)
    (cl-remf rest :type)
    (cl-remf rest :target)
    (cl-remf rest :template)
    `(,key ,description ,type ,target ,template ,@rest)))

(setq
 org-capture-templates
 (list (my/org-capture-template
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
        :clock-resume t)))


;;;; Refile
(defun my/org-refile-targets-with-vulpea ()
  "Return a list of filepaths suitable for `org-refile-targets'."
  (let* ((file-notes (vulpea-db-query (lambda (note)
                                        (let* ((level (vulpea-note-level note)))
                                          (equal 0 level)))))
         (filepaths (seq-map #'vulpea-note-path file-notes)))
    filepaths))

;; All file-level notes are refile targets.
(setq org-refile-targets '((my/org-refile-targets-with-vulpea . t)))
;; Setting to file means the candidate in the Refile interface looks like
;; "file.org/heading1/heading2/heading3".
;; Having the filename allows me to fuzzy search using Orderless.
(setq org-refile-use-outline-path 'file)
;; Setting this to nil means populate the Refile interface
;; with all target headlines at once.
;; This is useful because we are using Orderless.
;; Typically we type something like "filename partial-heading1 partial-heading2" to locate the target.
(setq org-outline-path-complete-in-steps nil)


;;;; Integrate `org-lint' with `flymake'.
(defun my/flymake-org-lint (report-fn &rest _args)
  "A flymake backend for `org-lint'.
REPORT-FN is respected."
  (let* ((source (current-buffer))
         (reports-alist (org-lint))
         diags)
    (dolist (element reports-alist)
      (pcase-let* ((`(,_id [,line ,_trust ,msg ,checker]) element)
                   (`(,beg . ,end) (flymake-diag-region source (string-to-number line)))
                   (code (symbol-name (org-lint-checker-name checker)))
                   (info (list "org-lint" code msg))
                   (diag (flymake-make-diagnostic source beg end :error info)))
        (push diag diags)))
    (funcall report-fn (nreverse diags))))
(add-hook 'org-mode-hook (lambda ()
                           (add-hook 'flymake-diagnostic-functions #'my/flymake-org-lint nil t)))

;;;; Archive
(defun my/org-event--timestamp ()
  "Return the timestamp object of the event at point, or nil.
SCHEDULED takes precedence over DEADLINE, which takes precedence
over the first active timestamp in the entry."
  (when-let* ((s (or (org-entry-get nil "SCHEDULED")
                     (org-entry-get nil "DEADLINE")
                     (org-entry-get nil "TIMESTAMP"))))
    (org-timestamp-from-string s)))

(defun my/org-event--past-p (timestamp)
  "Return non-nil if TIMESTAMP ended before today.
Repeating and diary timestamps are never considered past."
  (and (memq (org-element-property :type timestamp) '(active active-range))
       (not (org-element-property :repeater-type timestamp))
       (< (time-to-days (org-timestamp-to-time timestamp t)) (org-today))))

;;;###autoload
(defun my/org-archive-past-events ()
  "Refile past top-level events into a datetree.
The datetree is under `org-archive-sibling-heading'.
An event is a top-level headline with a planning or an active timestamp.
The datetree entry is taken from the start of that timestamp."
  (interactive)
  ;; Make `org-archive-sibling-heading' available.
  (require 'org-archive)
  (save-excursion
    (save-restriction
      (widen)
      (let* ((file (buffer-file-name))
             (archive (org-find-olp (list org-archive-sibling-heading) t))
             (events nil))
        ;; Collect first, because refiling moves headlines around.
        (org-map-entries
         (lambda ()
           (when-let* ((timestamp (my/org-event--timestamp))
                       (_ (/= (point) archive))
                       (_ (my/org-event--past-p timestamp)))
             (push (cons (point-marker) timestamp) events)))
         "LEVEL=1")
        (pcase-dolist (`(,marker . ,timestamp) (reverse events))
          (let* ((date (list (org-element-property :month-start timestamp)
                             (org-element-property :day-start timestamp)
                             (org-element-property :year-start timestamp)))
                 (target (save-excursion
                           (save-restriction
                             (goto-char archive)
                             (org-datetree-find-date-create date 'subtree-at-point)
                             (point)))))
            (goto-char marker)
            (org-refile nil nil (list org-archive-sibling-heading file nil target))
            (set-marker marker nil)))
        (set-marker archive nil)
        (message "Archived %d past event(s)" (length events))))))

(defun my/org-event--sort-key ()
  "Return the sort key of the top-level headline at point.
`org-archive-sibling-heading' sorts last.  Headlines without a usable
timestamp sort just before it, after all dated events."
  ;; Make `org-archive-sibling-heading' available.
  (require 'org-archive)
  (let* ((timestamp (my/org-event--timestamp)))
    (cond
     ((equal (org-get-heading t t t t) org-archive-sibling-heading)
      most-positive-fixnum)
     ((memq (org-element-property :type timestamp) '(active active-range))
      (float-time (org-timestamp-to-time timestamp)))
     (t
      most-positive-fixnum))))

;;;###autoload
(defun my/org-sort-events ()
  "Sort top-level events by timestamp.
`org-archive-sibling-heading' is kept last."
  (interactive)
  ;; Sort the whole buffer as a region, so that it works regardless of
  ;; where point is and whether the buffer starts with a headline.
  (save-mark-and-excursion
    (save-restriction
      (widen)
      (let* ((transient-mark-mode t))
        (goto-char (point-min))
        (set-mark (point-max))
        (org-sort-entries nil ?f #'my/org-event--sort-key #'<)))))

;;;; Latex
(setq org-preview-latex-default-process 'dvisvgm)
(setq org-format-latex-options (plist-put org-format-latex-options :scale 1.3))

;;;; Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((awk . t)
   (shell . t)
   (clojure . t)
   (emacs-lisp . t)
   (fennel . t)
   (sed . t)
   (lua . t)
   (js . t)
   (python . t)
   (ruby . t)))

(provide 'init-org-mode)
;;; init-org-mode.el ends here
