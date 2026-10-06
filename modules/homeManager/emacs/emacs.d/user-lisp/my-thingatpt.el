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
  "A regular expression matching a Org date such as '2006-01-02 Mon'.")

;;;###autoload
(defun my/thingatpt-org-date-increment (count)
  "Increment the Org date at point with COUNT.

Only year from 0001 to 9999 are supported.
Therefore, point does not move."
  (interactive "p")
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
          (goto-char point)))))

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
(defun my/thingatpt-iso8601-date-increment (count)
  "Increment the ISO8601 date at point with COUNT."
  (interactive "p")
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
          (goto-char point)))))

;;;###autoload
(defun my/thingatpt-iso8601-date-decrement (count)
  "Decrement the ISO8601 date at point with COUNT."
  (interactive "p")
  (my/thingatpt-iso8601-date-increment (- count)))

;;;; Integer
(defconst my/thingatpt-integer-regexp
  (rx-let ((sign (group-n 3 (? (in "-+"))))
           (binary-prefix (group-n 2 (or "0b" "0B")))
           (octal-prefix (group-n 2 (or "0o" "0O")))
           (hexadecimal-prefix (group-n 2 (or "0x" "0X")))
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
(defun my/thingatpt-integer-increment (count)
  "Increment integer at point with COUNT.

Always move point after the integer."
  (interactive "p")
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
                 ((or "0b" "0B") 2)
                 ((or "0o" "0O") 8)
                 ((or "0x" "0X") 16)
                 (_ 10)))
         (specifier (pcase prefix
                      ((or "0b" "0B") "%b")
                      ((or "0o" "0O") "%o")
                      ((or "0x" "0X") "%x")
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
    (goto-char (+ (match-beginning 0) (length formatted)))))

;;;###autoload
(defun my/thingatpt-integer-decrement (count)
  "Decrement integer at point with COUNT.

Always move point after the integer."
  (interactive "p")
  (my/thingatpt-integer-increment (- count)))

;;;; Configuration

(defcustom my/thingatpt-things
  `((:regexp
     ,my/thingatpt-org-date-regexp
     :increment
     my/thingatpt-org-date-increment
     :decrement
     my/thingatpt-org-date-decrement)
    (:regexp
     ,my/thingatpt-iso8601-date-regexp
     :increment
     my/thingatpt-iso8601-date-increment
     :decrement
     my/thingatpt-iso8601-date-decrement)
    (:regexp
     ,my/thingatpt-integer-regexp
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
                      for regexp = (plist-get thing :regexp)
                      if (and regexp (thing-at-point-looking-at regexp))
                      return thing))
              (increment (plist-get thing :increment)))
    t))

;;;###autoload
(defun my/thingatpt-increment (arg)
  "Increment thing at point with ARG."
  (interactive "P")
  (when-let* ((thing (cl-loop
                      for thing in my/thingatpt-things
                      for regexp = (plist-get thing :regexp)
                      if (and regexp (thing-at-point-looking-at regexp))
                      return thing))
              (increment (plist-get thing :increment)))
    (call-interactively increment)))

;;;###autoload
(defun my/thingatpt-decrement-p ()
  "Return non-nil if decrementing thing at point is possible."
  (interactive)
  (when-let* ((thing (cl-loop
                      for thing in my/thingatpt-things
                      for regexp = (plist-get thing :regexp)
                      if (and regexp (thing-at-point-looking-at regexp))
                      return thing))
              (decrement (plist-get thing :decrement)))
    t))

;;;###autoload
(defun my/thingatpt-decrement (arg)
  "Decrement thing at point with ARG."
  (interactive "P")
  (when-let* ((thing (cl-loop
                      for thing in my/thingatpt-things
                      for regexp = (plist-get thing :regexp)
                      if (and regexp (thing-at-point-looking-at regexp))
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
