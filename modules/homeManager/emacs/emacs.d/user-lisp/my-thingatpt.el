;;; my-thingatpt.el --- my-thingatpt.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;;; Org date

(defconst my/thingatpt-org-date-regexp
  (rx
   word-start
   (group-n 1 (repeat 4 digit))
   "-"
   (group-n 2 (or (seq "0" digit)
                  (seq "1" (in "012"))))
   "-"
   (group-n 3 (or (seq (in "012") digit)
                  (seq "3" (in "01"))))
   " "
   (group-n 4 (or "Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun"))
   word-end)
  "A regular expression matching an Org date such as '2006-01-02 Mon'.")

;;;###autoload
(defun my/thingatpt-org-date-match ()
  "Return non-nil if point is in or after an Org date."
  (interactive)
  (my/thingatpt-point-in-or-after-regexp my/thingatpt-org-date-regexp))

;;;###autoload
(defun my/thingatpt-org-date-increment (count)
  "Increment the Org date at point with COUNT.

Only year from 0001 to 9999 are supported.
Therefore, point does not move."
  (interactive "p")
  (when (my/thingatpt-point-in-or-after-regexp my/thingatpt-org-date-regexp)
    (let* ((original (buffer-substring-no-properties (match-beginning 0) (match-end 0)))
           (year (string-to-number (buffer-substring-no-properties (match-beginning 1) (match-end 1))))
           (month (string-to-number (buffer-substring-no-properties (match-beginning 2) (match-end 2))))
           (day (string-to-number (buffer-substring-no-properties (match-beginning 3) (match-end 3))))
           (date (list month day year))
           (point (point))
           new-date)
      (unwind-protect
          (progn
            ;; Handle 0000-mm-dd
            (unless (calendar-date-is-valid-p date)
              (error "Date %s is not supported" original))
            (cond
             ((>= point (match-beginning 3))
              (setq new-date (my/calendar-gregorian-add date :days count)))
             ((>= point (match-beginning 2))
              (setq new-date (my/calendar-gregorian-add date :months count)))
             (t
              (setq new-date (my/calendar-gregorian-add date :years count))))
            (when (> (calendar-extract-year new-date) 9999)
              (error "Year must be <= 9999"))
            (replace-region-contents
             (match-beginning 0)
             (match-end 0)
             (my/calendar-gregorian-to-org-string new-date))
            (goto-char point))))))

;;;###autoload
(defun my/thingatpt-org-date-decrement (count)
  "Decrement the Org date at point with COUNT.

Only year from 0001 to 9999 are supported.
Therefore, point does not move."
  (interactive "p")
  (my/thingatpt-org-date-increment (- count)))

;;;; ISO8601 date

(defconst my/thingatpt-iso8601-date-regexp
  (rx
   word-start
   (group-n 1 (repeat 4 digit))
   "-"
   (group-n 2 (or (seq "0" digit)
                  (seq "1" (in "012"))))
   "-"
   (group-n 3 (or (seq (in "012") digit)
                  (seq "3" (in "01"))))
   word-end)
  "A regular expression matching a ISO8601 date such as '2006-01-02'.")

;;;###autoload
(defun my/thingatpt-iso8601-date-match ()
  "Return non-nil if point is in or after a ISO8601 date."
  (interactive)
  (my/thingatpt-point-in-or-after-regexp my/thingatpt-iso8601-date-regexp))

;;;###autoload
(defun my/thingatpt-iso8601-date-increment (count)
  "Increment the ISO8601 date at point with COUNT."
  (interactive "p")
  (when (my/thingatpt-point-in-or-after-regexp my/thingatpt-iso8601-date-regexp)
    (let* ((original (buffer-substring-no-properties (match-beginning 0) (match-end 0)))
           (year (string-to-number (buffer-substring-no-properties (match-beginning 1) (match-end 1))))
           (month (string-to-number (buffer-substring-no-properties (match-beginning 2) (match-end 2))))
           (day (string-to-number (buffer-substring-no-properties (match-beginning 3) (match-end 3))))
           (date (list month day year))
           (point (point))
           new-date)
      (unwind-protect
          (progn
            ;; Handle 0000-mm-dd
            (unless (calendar-date-is-valid-p date)
              (error "Date %s is not supported" original))
            (cond
             ((>= point (match-beginning 3))
              (setq new-date (my/calendar-gregorian-add date :days count)))
             ((>= point (match-beginning 2))
              (setq new-date (my/calendar-gregorian-add date :months count)))
             (t
              (setq new-date (my/calendar-gregorian-add date :years count))))
            (when (> (calendar-extract-year new-date) 9999)
              (error "Year must be <= 9999"))
            (replace-region-contents
             (match-beginning 0)
             (match-end 0)
             (my/calendar-gregorian-iso8601-date-string new-date))
            (goto-char point))))))

;;;###autoload
(defun my/thingatpt-iso8601-date-decrement (count)
  "Decrement the ISO8601 date at point with COUNT."
  (interactive "p")
  (my/thingatpt-iso8601-date-increment (- count)))

;;;; Integer
(defconst my/thingatpt-integer-regexp
  (rx-let ((sign (group-n 3 (? (in "-+"))))
           (binary-prefix (group-n 2 (or "0b" "0B" "#b" "#B")))
           (octal-prefix (group-n 2 (or "0o" "0O" "#o" "#O")))
           (hexadecimal-prefix (group-n 2 (or "0x" "0X" "#x" "#X")))
           (binary-digit (in "01"))
           (octal-digit (in "01234567"))
           (decimal-digit (in "0123456789"))
           (hexadecimal-digit (in "0123456789abcdefABCDEF"))
           (underscore-digit (d) (seq "_" d))
           (underscore-digit-or-digit (d) (or (underscore-digit d) d))
           (non-decimal-integer (prefix d) (seq prefix (group-n 1 d (* (underscore-digit-or-digit d)))))
           (decimal-integer (group-n 1 decimal-digit (* (underscore-digit-or-digit decimal-digit))))
           (binary-integer (non-decimal-integer binary-prefix binary-digit))
           (octal-integer (non-decimal-integer octal-prefix octal-digit))
           (hexadecimal-integer (non-decimal-integer hexadecimal-prefix hexadecimal-digit)))
    (rx
     ;; We should put word-start here.
     ;; But if we place it, a minus sign will never be included in the match.
     sign
     (or
      binary-integer
      octal-integer
      decimal-integer
      hexadecimal-integer)
     word-end))
  "A regular expression for integers.")

;;;###autoload
(defun my/thingatpt-integer-match ()
  "Return non-nil if point is in or after an integer."
  (interactive)
  (my/thingatpt-point-in-or-after-regexp my/thingatpt-integer-regexp))

;;;###autoload
(defun my/thingatpt-integer-increment (count)
  "Increment integer at point with COUNT.

Always move point after the integer."
  (interactive "p")
  (when (my/thingatpt-point-in-or-after-regexp my/thingatpt-integer-regexp)
    (let* ((sign (or (when-let* ((beg (match-beginning 3))
                                 (end (match-end 3)))
                       (buffer-substring-no-properties beg end))
                     ""))
           (prefix (or (when-let* ((beg (match-beginning 2))
                                   (end (match-end 2)))
                         (buffer-substring-no-properties beg end))
                       ""))
           (digits-with-underscore (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
           (digits (string-replace "_" "" digits-with-underscore))
           (base (pcase prefix
                   ((or "0b" "0B" "#b" "#B") 2)
                   ((or "0o" "0O" "#o" "#O") 8)
                   ((or "0x" "0X" "#x" "#X") 16)
                   (_ 10)))
           (specifier (pcase prefix
                        ((or "0b" "0B" "#b" "#B") "%b")
                        ((or "0o" "0O" "#o" "#O") "%o")
                        ((or "0x" "0X" "#x" "#X") "%x")
                        (_ "%d")))
           (unsigned-value (string-to-number digits base))
           (signed-value (if (string= sign "-")
                             (- unsigned-value)
                           unsigned-value))
           (incremented-value (+ signed-value count))
           (sign (cond
                  ((and (< signed-value 0) (>= incremented-value 0))
                   "")
                  ((and (>= signed-value 0) (< incremented-value 0))
                   "-")
                  (t
                   sign)))
           (abs-value (abs incremented-value))
           (formatted (format (concat "%s%s" specifier) sign prefix abs-value)))
      (replace-region-contents
       (match-beginning 0)
       (match-end 0)
       formatted)
      (goto-char (+ (match-beginning 0) (length formatted))))))

;;;###autoload
(defun my/thingatpt-integer-decrement (count)
  "Decrement integer at point with COUNT.

Always move point after the integer."
  (interactive "p")
  (my/thingatpt-integer-increment (- count)))

;;;; Helpers

(defun my/thingatpt-point-in-or-after-regexp (regexp)
  "Return non-nil if point is in or after a match for REGEXP.
Different from `thing-at-point-looking-at', only the current line is searched.

Point is not moved.
Match data is set."
  (save-excursion
    (let* ((point (point))
           (beg (progn
                  (move-beginning-of-line nil)
                  (point)))
           (end (progn
                  (move-end-of-line nil)
                  (point)))
           match-end
           match-beginning)
      (goto-char beg)
      (cl-block loop
        ;; Limit the search to current line.
        (while (<= (point) end)
          (setq match-end (re-search-forward regexp end t))
          ;; No match in current line.
          (unless match-end
            (cl-return-from loop nil))
          (setq match-beginning (match-beginning 0))
          ;; The match begins after point.
          ;; That means no match.
          (when (> match-beginning point)
            (cl-return-from loop nil))
          ;; match-beginning <= point and match-end >= point
          ;; That means a match.
          (when (>= match-end point)
            (cl-return-from loop match-end))
          ;; match-beginning <= point and match-end < point
          ;; Let the loop run again.
          ;; Normally we can just do nothing and let the loop run again,
          ;; but if the regexp matches an empty string and thus stick at point,
          ;; we move point 1 character forward.
          (when (eql match-beginning match-end)
            (forward-char)))))))

;;;; Configuration

(defcustom my/thingatpt-things
  `((:match
     my/thingatpt-org-date-match
     :increment
     my/thingatpt-org-date-increment
     :decrement
     my/thingatpt-org-date-decrement)
    (:match
     my/thingatpt-iso8601-date-match
     :increment
     my/thingatpt-iso8601-date-increment
     :decrement
     my/thingatpt-iso8601-date-decrement)
    (:match
     my/thingatpt-integer-match
     :increment
     my/thingatpt-integer-increment
     :decrement
     my/thingatpt-integer-decrement))
  "A list of things that support increment and decrement.

The first thing that matches thing at point is used.
Therefore, more specific thing should be placed at the front of the list.

The commands in :increment and :decrement must
edit the buffer in-place, and move point such that the command itself can be repeated.")

(defvar-keymap my/thingatpt-mode-map
  :doc "Key map for `my/thingatpt-mode'.

The keybindings are contextual.
If keybinding is not applicable at point,
it will fall back to major mode keymap or the global keymap.
Therefore, it should be safe to enable this minor mode globally."
  "S-<up>" `(menu-item
             ""
             my/thingatpt-increment
             :filter ,(lambda (cmd)
                        (when (my/thingatpt-increment-p)
                          cmd)))
  "S-<down>" `(menu-item
               ""
               my/thingatpt-decrement
               :filter ,(lambda (cmd)
                          (when (my/thingatpt-decrement-p)
                            cmd))))

;;;; Commands

;;;###autoload
(defun my/thingatpt-increment-p ()
  "Return non-nil if incrementing thing at point is possible."
  (interactive)
  (when-let* ((thing (cl-loop
                      for thing in my/thingatpt-things
                      for match = (plist-get thing :match)
                      if (and match (funcall match))
                      return thing))
              (increment (plist-get thing :increment)))
    t))

;;;###autoload
(defun my/thingatpt-increment (arg)
  "Increment thing at point with ARG."
  (interactive "P")
  (when-let* ((thing (cl-loop
                      for thing in my/thingatpt-things
                      for match = (plist-get thing :match)
                      if (and match (funcall match))
                      return thing))
              (increment (plist-get thing :increment)))
    (call-interactively increment)))

;;;###autoload
(defun my/thingatpt-decrement-p ()
  "Return non-nil if decrementing thing at point is possible."
  (interactive)
  (when-let* ((thing (cl-loop
                      for thing in my/thingatpt-things
                      for match = (plist-get thing :match)
                      if (and match (funcall match))
                      return thing))
              (decrement (plist-get thing :decrement)))
    t))

;;;###autoload
(defun my/thingatpt-decrement (arg)
  "Decrement thing at point with ARG."
  (interactive "P")
  (when-let* ((thing (cl-loop
                      for thing in my/thingatpt-things
                      for match = (plist-get thing :match)
                      if (and match (funcall match))
                      return thing))
              (decrement (plist-get thing :decrement)))
    (call-interactively decrement)))

;;;; Minor mode
;;;###autoload
(define-minor-mode my/thingatpt-mode
  "Toggle my/thingatpt-mode."
  :keymap my/thingatpt-mode-map)

(provide 'my-thingatpt)
;;; my-thingatpt.el ends here
