;;; my-org.el --- my-org.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(eval-when-compile (require 'my-holidays))
(require 'cl-lib)
(require 'calendar)
(require 'holidays)
(require 'org-element)

(defvar org-agenda-buffer)
(defvar org-agenda-current-date)
(declare-function org-agenda-span-to-ndays "org-agenda")
(declare-function my/calendar-gregorian-to-org-string "my-calendar")

(defvar my/org-calendar-holiday--cache-key nil
  "(`org-starting-day' . `org-agenda-current-span').")

(defvar my/org-calendar-holiday--cache nil
  "Map from an absolute day number to a list of holiday strings.")

(defun my/org-calendar-holiday--build (start-abs end-abs-exclusive)
  "Fill `my/org-calendar-holiday--cache'.

START-ABS and END-ABS-EXCLUSIVE may span more than 12 months."
  (unless my/org-calendar-holiday--cache
    (setq my/org-calendar-holiday--cache (make-hash-table :test #'eql)))
  (clrhash my/org-calendar-holiday--cache)
  (let* ((start (calendar-gregorian-from-absolute start-abs))
         (end-inclusive (calendar-gregorian-from-absolute (1- end-abs-exclusive)))
         (start-year (calendar-extract-year start))
         (end-year (calendar-extract-year end-inclusive))
         (year-count (1+ (- end-year start-year))))
    (dotimes (idx year-count)
      (let* ((holidays (my/holiday-bind (calendar-holiday-list) :year (+ start-year idx))))
        (dolist (holiday holidays)
          (let* ((date (nth 0 holiday))
                 (date-abs (calendar-absolute-from-gregorian date))
                 (description (nth 1 holiday)))
            (puthash date-abs (append
                               (gethash date-abs my/org-calendar-holiday--cache)
                               (list description))
                     my/org-calendar-holiday--cache)))))))

;;;###autoload
(defun my/org-calendar-holiday--around (orig-fun &rest args)
  "Serve `org-calendar-holiday' from a cache while `org-agenda-list' builds.
Call ORIG-FUN with ARGS when the agenda range is not available."
  (if-let* ((_ (buffer-live-p org-agenda-buffer))
            (_ (not (eq org-agenda-buffer (current-buffer))))
            (_ (local-variable-p 'org-starting-day org-agenda-buffer))
            (_ (local-variable-p 'org-agenda-current-span org-agenda-buffer))
            (start-abs (buffer-local-value 'org-starting-day org-agenda-buffer))
            (span (buffer-local-value 'org-agenda-current-span org-agenda-buffer))
            (cache-key (cons start-abs span))
            (ndays (org-agenda-span-to-ndays span start-abs))
            (end-abs-exclusive (+ start-abs ndays))
            (org-agenda-current-date-abs (calendar-absolute-from-gregorian org-agenda-current-date)))
      (progn
        (unless (equal cache-key my/org-calendar-holiday--cache-key)
          (setq my/org-calendar-holiday--cache-key nil)
          (my/org-calendar-holiday--build start-abs end-abs-exclusive)
          (setq my/org-calendar-holiday--cache-key cache-key))
        (unless (<= start-abs org-agenda-current-date-abs end-abs-exclusive)
          (error "Variable org-agenda-current-date %S is outside the agenda range [ %S %S )"
                 org-agenda-current-date
                 (calendar-gregorian-from-absolute start-abs)
                 (calendar-gregorian-from-absolute end-abs-exclusive)))
        (let* ((holiday-strings (gethash org-agenda-current-date-abs my/org-calendar-holiday--cache)))
          (when holiday-strings
            (mapconcat #'identity holiday-strings "; "))))
    (apply orig-fun args)))

;;;###autoload
(defun my/org-calendar-holiday--invalidate (&rest _args)
  "Invalidate the cache."
  (setq my/org-calendar-holiday--cache-key nil))

;;;###autoload
(defun my/org-agenda-optimize--around (orig-fun &rest args)
  "Memoize `abbreviate-file-name' and bind `file-name-coding-system'.

On my macOS, `file-name-coding-system' is utf-8-hfs-unix.
With this coding system, it will perform unicode normalization.
See https://github.com/emacs-mirror/emacs/blob/emacs-31.1/lisp/international/ucs-normalize.el
Binding `file-name-coding-system' to utf-8-unix skips the normalization.

`abbreviate-file-name' will be called many times to
construct the tip tool of agenda line.

Call ORIG-FUN with ARGS."
  (let* ((file-name-coding-system 'utf-8-unix)
         (cache (make-hash-table :test #'equal))
         (abbreviate (symbol-function 'abbreviate-file-name)))
    (cl-letf (((symbol-function 'abbreviate-file-name)
               (lambda (filename)
                 (or (gethash filename cache)
                     (puthash filename (funcall abbreviate filename) cache)))))
      (apply orig-fun args))))

;;;###autoload
(defun my/org-element-timestamp-at-point ()
  "Return a timestamp object at point.

Return nil if there is no timestamp object at point."
  (let* ((context (org-element-context)))
    (pcase (org-element-type context)
      ('timestamp context)
      ('clock (org-element-property :value context))
      ('planning (seq-find (lambda (timestamp)
                             (and timestamp
                                  (>= (point) (org-element-begin timestamp))
                                  (< (point) (org-element-end timestamp))))
                           (seq-map (lambda (property)
                                      (org-element-property property context))
                                    '(:scheduled :deadline :closed)))))))

;;;###autoload
(defun my/org-element-timestamp-date-at-point ()
  "Return a Gregorian date of the timestamp object at point.

Return nil if point is not on a date."
  (when-let* ((timestamp (my/org-element-timestamp-at-point)))
    (pcase (org-element-property :type timestamp)
      ((or 'active 'inactive)
       (list (org-element-property :month-start timestamp)
             (org-element-property :day-start timestamp)
             (org-element-property :year-start timestamp)))
      ((or 'active-range 'inactive-range)
       (pcase (org-element-property :range-type timestamp)
         ('daterange
          (pcase (org-at-timestamp-p 'lax)
            ;; The first "-" in "--".
            ((and 'after (guard (eql (match-beginning 0) (org-element-begin timestamp))))
             nil)
            ;;            trailing space                                 repeater
            ((or 'bracket 'after         'year 'month 'day 'hour 'minute (pred integerp))
             (list
              (string-to-number (buffer-substring-no-properties (match-beginning 3) (match-end 3)) 10)
              (string-to-number (buffer-substring-no-properties (match-beginning 4) (match-end 4)) 10)
              (string-to-number (buffer-substring-no-properties (match-beginning 2) (match-end 2)) 10)))))
         ('timerange
          (list (org-element-property :month-start timestamp)
                (org-element-property :day-start timestamp)
                (org-element-property :year-start timestamp))))))))

;;;###autoload
(defun my/org-element-timestamp-print-human-readable-difference-in-days ()
  "Print the difference between the Gregorian date at point and today.

Do nothing if there is no Gregorian date at point.
Always return nil."
  (interactive)
  (when-let* ((date (my/org-element-timestamp-date-at-point))
              (today (calendar-current-date))
              (date-abs (calendar-absolute-from-gregorian date))
              (today-abs (calendar-absolute-from-gregorian today))
              (difference (- date-abs today-abs))
              (formatted-date (my/calendar-gregorian-to-org-string date)))
    (cond
     ((> difference 0)
      (message "%d day(s) until %s" difference formatted-date))
     ((< difference 0)
      (message "%d day(s) since %s" (abs difference) formatted-date))
     (t
      (message "Today is %s" formatted-date))))
  nil)

(provide 'my-org)
;;; my-org.el ends here
