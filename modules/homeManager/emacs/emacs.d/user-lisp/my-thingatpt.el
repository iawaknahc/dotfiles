;;; my-thingatpt.el --- my-thingatpt.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'cl-lib)

;; `calendar-date-is-valid-p'
;; `calendar-extract-year'
(require 'calendar)

;; `my/calendar-gregorian-add'
;; `my/calendar-gregorian-to-org-string'
;; `my/calendar-gregorian-iso8601-date-string'
(require 'my-calendar)

;;;; Org date

(defconst my/thingatpt-org-date-regexp
  (rx
   (group-n 5 (* digit))
   (group-n 6
     (group-n 1 (repeat 4 digit))
     "-"
     (group-n 2 (or (seq "0" digit)
                    (seq "1" (in "012"))))
     "-"
     (group-n 3 (or (seq (in "012") digit)
                    (seq "3" (in "01"))))
     " "
     (group-n 4 (or "Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")))
   (group-n 7 (* (in "a-zA-Z"))))
  "A regular expression matching an Org date such as '2006-01-02 Mon'.

Group 6 is the date.
Group 5 is the digits before the date, and group 7 is the letters after it.
If either of them is not empty, the date is a part of something longer,
and the match must be rejected.
See `my/thingatpt-org-date-match'.")

;;;###autoload
(defun my/thingatpt-org-date-match ()
  "Return non-nil if point is in or after an Org date.

Match data is set according to `my/thingatpt-org-date-regexp'."
  (interactive)
  (and (my/thingatpt-point-in-or-after-regexp my/thingatpt-org-date-regexp)
       (my/thingatpt--match-empty-p 5)
       (my/thingatpt--match-empty-p 7)))

;;;###autoload
(defun my/thingatpt-org-date-increment (count)
  "Increment the Org date at point with COUNT.

Only year from 0001 to 9999 are supported.
Therefore, point does not move."
  (interactive "p")
  (when (my/thingatpt-org-date-match)
    (let* ((original (buffer-substring-no-properties (match-beginning 6) (match-end 6)))
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
             (match-beginning 6)
             (match-end 6)
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
   (group-n 5 (* digit))
   (group-n 6
     (group-n 1 (repeat 4 digit))
     "-"
     (group-n 2 (or (seq "0" digit)
                    (seq "1" (in "012"))))
     "-"
     (group-n 3 (or (seq (in "012") digit)
                    (seq "3" (in "01")))))
   (group-n 7 (* digit)))
  "A regular expression matching a ISO8601 date such as '2006-01-02'.

Group 6 is the date.
Group 5 is the digits before the date, and group 7 is the digits after it.
If either of them is not empty, the date is a part of something longer,
and the match must be rejected.
See `my/thingatpt-iso8601-date-match'.")

;;;###autoload
(defun my/thingatpt-iso8601-date-match ()
  "Return non-nil if point is in or after a ISO8601 date.

Match data is set according to `my/thingatpt-iso8601-date-regexp'."
  (interactive)
  (and (my/thingatpt-point-in-or-after-regexp my/thingatpt-iso8601-date-regexp)
       (my/thingatpt--match-empty-p 5)
       (my/thingatpt--match-empty-p 7)))

;;;###autoload
(defun my/thingatpt-iso8601-date-increment (count)
  "Increment the ISO8601 date at point with COUNT."
  (interactive "p")
  (when (my/thingatpt-iso8601-date-match)
    (let* ((original (buffer-substring-no-properties (match-beginning 6) (match-end 6)))
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
             (match-beginning 6)
             (match-end 6)
             (my/calendar-gregorian-iso8601-date-string new-date))
            (goto-char point))))))

;;;###autoload
(defun my/thingatpt-iso8601-date-decrement (count)
  "Decrement the ISO8601 date at point with COUNT."
  (interactive "p")
  (my/thingatpt-iso8601-date-increment (- count)))

;;;; Integer
(defconst my/thingatpt-integer-regexp
  (rx-let ((sign (in "-+"))
           (binary-prefix (or "0b" "0B"))
           (octal-prefix (or "0o" "0O"))
           (hexadecimal-prefix (or "0x" "0X"))

           (binary-digit (in "01"))
           (octal-digit (in "01234567"))
           (decimal-digit (in "0123456789"))
           (hexadecimal-digit (in "0123456789abcdefABCDEF"))

           (underscore-digit (d) (seq "_" d))
           (underscore-digit-or-digit (d) (or (underscore-digit d) d))
           (digits (d) (seq d (* (underscore-digit-or-digit d))))
           (binary-digits (digits binary-digit))
           (octal-digits (digits octal-digit))
           (decimal-digits (digits decimal-digit))
           (hexadecimal-digits (digits hexadecimal-digit))

           (exponent-indicator (or "e" "E"))

           (decimal-integer (seq
                             (group-n 1
                               (group-n 2 (? sign))
                               (group-n 4 decimal-digits))
                             (? exponent-indicator (group-n 5
                                                     (group-n 6 (? sign))
                                                     (group-n 7 decimal-digits)))))
           (binary-integer (group-n 1
                             (group-n 2 (? sign))
                             (group-n 3 binary-prefix)
                             (group-n 4 binary-digits)))
           (octal-integer (group-n 1
                            (group-n 2 (? sign))
                            (group-n 3 octal-prefix)
                            (group-n 4 octal-digits)))
           (hexadecimal-integer (group-n 1
                                  (group-n 2 (? sign))
                                  (group-n 3 hexadecimal-prefix)
                                  (group-n 4 hexadecimal-digits))))
    (rx
     (or
      binary-integer
      octal-integer
      hexadecimal-integer
      decimal-integer)
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
    (let* ((integral-digits-with-underscore (my/thingatpt--buffer-substring-no-properties-of-match 4))
           (base-prefix (my/thingatpt--buffer-substring-no-properties-of-match 3))
           (integral-sign (my/thingatpt--buffer-substring-no-properties-of-match 2))
           (exponent-digits-with-underscore (my/thingatpt--buffer-substring-no-properties-of-match 7))
           (exponent-sign (my/thingatpt--buffer-substring-no-properties-of-match 6)))
      ;; Increment either the integral part or the exponent part,
      ;; depending on where point is.
      (cond
       ;; The exponent part exists and the point is in the exponent part.
       ;; Increment the exponent part.
       ((and (match-beginning 5) (>= (point) (match-beginning 5)))
        (let* ((result (my/thingatpt--increment exponent-sign "" exponent-digits-with-underscore count))
               (exponent-beg (match-beginning 5)))
          (replace-region-contents
           (match-beginning 5)
           (match-end 5)
           result)
          ;; Move point to the end of the exponent part.
          (goto-char (+ exponent-beg (length result)))))
       ;; Otherwise, increment the integral part.
       (t
        (let* ((result (my/thingatpt--increment integral-sign base-prefix integral-digits-with-underscore count))
               (integral-beg (match-beginning 1)))
          (replace-region-contents
           (match-beginning 1)
           (match-end 1)
           result)
          ;; Move point to the end of the integral part.
          (goto-char (+ integral-beg (length result)))))))))

;;;###autoload
(defun my/thingatpt-integer-decrement (count)
  "Decrement integer at point with COUNT.

Always move point after the integer."
  (interactive "p")
  (my/thingatpt-integer-increment (- count)))

;;;; Helpers

;;;###autoload
(defun my/thingatpt--buffer-substring-no-properties-of-match (group)
  "Return the substring of match group GROUP, or an empty string."
  (or (when-let* ((beg (match-beginning group))
                  (end (match-end group)))
        (buffer-substring-no-properties beg end))
      ""))

;;;###autoload
(defun my/thingatpt--match-empty-p (group)
  "Return non-nil if match group GROUP is empty, or did not match."
  (eql (match-beginning group) (match-end group)))

;;;###autoload
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

;;;###autoload
(defun my/thingatpt--base-prefix-to-base (base-prefix)
  "Convert BASE-PREFIX to its numeric value."
  (pcase base-prefix
    ((or "0b" "0B") 2)
    ((or "0o" "0O") 8)
    ((or "0x" "0X") 16)
    (_ 10)))

;;;###autoload
(defun my/thingatpt--preferred-sign (sign sign-value)
  "Return - if SIGN-VALUE is negative.

Otherwise, if SIGN is +, return +.
Otherwise return an empty string."
  (cond
   ((< sign-value 0) "-")
   ((string= sign "+") "+")
   (t "")))

;;;###autoload
(defun my/thingatpt--increment (sign base-prefix digits-with-underscore count)
  "Increment DIGITS-WITH-UNDERSCORE whose sign is SIGN in base indicated by BASE-PREFIX with COUNT.

BASE-PREFIX is a string accepted by `my/thingatpt--base-prefix-to-base'.
DIGITS-WITH-UNDERSCORE is a string whose characters must be valid with respect to BASE-PREFIX, or underscores.
SIGN is a string either an empty string, -, or +.
COUNT is an integer.

Return a string representing the incremented value.
The underscores are kept if possible."
  (let* ((sign-value (if (string= sign "-") -1 1))
         (digits (string-replace "_" "" digits-with-underscore))
         (base (my/thingatpt--base-prefix-to-base base-prefix))
         (digits-value (string-to-number digits base))
         (value (* sign-value digits-value))
         (result-value (+ value count))
         (result-sign (my/thingatpt--preferred-sign sign result-value))
         (format-specifier (pcase base
                             (2 "%b")
                             (8 "%o")
                             (16 "%x")
                             (_ "%d")))
         (result-digits (format format-specifier (abs result-value)))
         (result-idx (1- (length result-digits)))
         (digits-idx (1- (length digits-with-underscore)))
         list)
    (while (>= result-idx 0)
      ;; Copy the digit and adjust index.
      (setq list (cons (aref result-digits result-idx) list))
      (setq result-idx (1- result-idx))
      ;; Assume the position of digits-idx is also a digit.
      (setq digits-idx (1- digits-idx))

      ;; Use a loop to copy the preceding underscores.
      (cl-block loop
        ;; No need to run this loop if we have copied all digits.
        (while (>= result-idx 0)
          (cond
           ;; digits exhausted. No need to look at it anymore.
           ((< digits-idx 0)
            (cl-return-from loop))
           ;; Copy the underscore.
           ((eql ?_ (aref digits-with-underscore digits-idx))
            (setq list (cons ?_ list))
            (setq digits-idx (1- digits-idx)))
           ;; It is not an underscore.
           (t
            (cl-return-from loop))))))
    (format "%s%s%s" result-sign base-prefix (concat list))))

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
