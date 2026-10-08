;;; my-thingatpt.el --- my-thingatpt.el -*- lexical-binding: t -*-
;;; Commentary:

;; This library increments and decrements the thing at point.
;; The supported things are Org dates, ISO8601 dates, and integers.
;;
;; In the examples below, | denotes the position of point.
;;
;; 1. Overview
;;
;; Each thing is an entry in `my/thingatpt-things', which has a match
;; function, an increment command, and a decrement command.  The first
;; thing whose match function returns non-nil is used, so a more
;; specific thing must come first.  For example, 2006-01-|02 is an
;; ISO8601 date, and also three integers.
;;
;; A match function answers whether point is in or right after the
;; thing.  Only the current line is searched.
;;
;; 2. Where a thing begins and ends
;;
;; The regexps do not use word-start and word-end.  Whether a thing
;; matches is decided by what is right before it, and what is right
;; after it.  The neighbors considered are the line edges, whitespace,
;; digits, letters, and each ASCII symbol on its own.
;;
;; The symbols are not grouped into classes such as closing brackets.
;; A symbol can play more than one role.  For example, > closes
;; <2006-01-02 Mon>, and it is also an operator in x>-1.
;;
;; A line is scanned from left to right.  A rejected match is consumed
;; as a whole, and the scan resumes at its end.  For example, in
;; 2006-01-0203-04-05, 2006-01-0203 is rejected and consumed, so
;; 0203-04-05 is never tried.
;;
;; 3. Verdicts for dates
;;
;; A date is rejected only by a neighbor that could extend it, which is
;; a neighbor of the same kind as the character at its edge.
;;
;; - A digit before an Org date or an ISO8601 date.
;;   12006-01-02 does not match.
;; - A digit after an ISO8601 date.
;;   2006-01-023 does not match.
;; - A letter after an Org date.
;;   2006-01-02 Monday does not match.
;;
;; Every other neighbor matches.  In particular, these match:
;;
;;   +2006-01-02   -2006-01-02   <2006-01-02>   log_2006-01-02
;;   a2006-01-02   2006-01-02T15:04:05Z   2006-01-02_notes.md
;;
;; 4. Verdicts for integers
;;
;; An integer is either a decimal, or a non-decimal.  A non-decimal has
;; either the C-style base prefix 0b, 0o, or 0x, or the Elisp-style base
;; prefix #b, #o, or #x.
;;
;; 4.1. Before the integer
;;
;; Nothing before the integer rejects it.  a|1 and _|1 match 1.
;;
;; 4.2. The sign
;;
;; A + or - right before the integer is its sign, unless it is demoted
;; by the character before it.  The demoting characters are the digits,
;; the letters, and _ + - ) ] }.  See
;; `my/thingatpt-sign-demoting-regexp'.
;;
;;   1-|2      matches 2     a-|1      matches 1     --|1   matches 1
;;   f(x)-|1   matches 1     a[0]-|1   matches 1     x_-|1  matches 1
;;   (-|1      matches -1    x=-|1     matches -1    x>-|1  matches -1
;;   "-|1"     matches -1    '-|1'     matches -1
;;
;; A demoted + or - is not part of the match, so a|-1 matches nothing,
;; and 1|-2 matches 1.
;;
;; Some symbols are ambiguous, and the verdict is a judgement call.
;; There is an asymmetry which is used as the tie-breaker.  Wrongly
;; keeping a sign can delete an operator, since f(x)-|1 would become
;; f(x)0.  Wrongly demoting a sign only reverses the direction.
;;
;; - ) demotes.  The cost is that the C cast (size_t)-1 is incremented
;;   in the wrong direction.
;; - " and ' do not demote, because a quoted -1 is more common than a
;;   subtraction from a string.  The cost is that 'a'-|1 becomes 'a'0.
;;
;; The sign of the exponent part is never demoted, because it is inside
;; the integer.  The same goes for the sign of an Elisp-style
;; non-decimal.  See 4.5.
;;
;; 4.3. After a decimal
;;
;; Nothing after a decimal rejects it.  What follows is a suffix, and it
;; is not part of the match.
;;
;;   1|px   1|km   1|UL   1|f32   all match 1
;;
;; - e or E is an exponent indicator only if it is followed by an
;;   optional sign, and at least one digit.  1|e and 1|e+ match 1.
;; - 0 followed by b, o, or x is a base prefix, and it is never the
;;   decimal 0.  It applies only if the digits are exactly 0, so 10|b
;;   matches 10.
;; - The digits in a suffix are an integer of their own.  1f3|2 matches
;;   32.  It follows from 4.1.
;;
;; 4.4. After a C-style non-decimal
;;
;; Some letters are digits in some bases, so digits and letters are read
;; relative to the base.  A foreign digit is a decimal digit which is
;; not a digit of the base, such as 2 in binary, and 8 in octal.
;; Hexadecimal has no foreign digits.
;;
;; - The base prefix must be followed by at least one digit of the base.
;;   0|x, 0|xg, and 0|b2 match nothing.
;; - The digits are the longest run of the digits of the base.
;; - If the digits are followed by a foreign digit, nothing matches.
;;   0b1|2 matches nothing, because no language writes it, and matching
;;   0b1 would turn it into 0b102.
;; - Anything else that follows is a suffix.  0x1|23m matches 0x123, and
;;   0b1|u8 matches 0b1.
;; - A rejected non-decimal also consumes the letters, digits, and
;;   underscores that follow.  Otherwise, 2 in 0b2 would match as a
;;   decimal.
;;
;; The longest run settles the ambiguities.
;;
;;   0x1e3       e is a digit, not an exponent indicator.
;;   0x10em      e is a digit, so the suffix is m.
;;   0x0b1       b is a digit, not a base prefix.
;;   0b1e5       0b1 with the suffix e5.  Only decimals have exponent.
;;   1920x1080   1920 and 1080.  1920 is taken first, so 0x1080 is
;;               never tried.
;;
;; 4.5. Elisp-style non-decimal
;;
;; The order is base prefix, sign, and digits, such as #x-10, while the
;; order of the C-style is sign, base prefix, and digits, such as -0x10.
;;
;; - The sign is inside the integer, so it is never demoted.  A + or -
;;   before # is not part of the match.  -#x1|0 matches #x10.
;; - Underscores are not allowed between digits.  #b1|_0 matches #b1.
;; - The digits are the longest run of the digits of the base.
;; - There is no suffix, as in the Elisp reader.  If the digits are
;;   followed by a letter, or a foreign digit, nothing matches.  #b1|2,
;;   #b1|e5, and #xf|g match nothing.  The letters, digits, and
;;   underscores that follow are consumed.
;; - Anything else that follows is not part of the match.  #xf|_g
;;   matches #xf, because the Elisp reader reads it as 15.
;; - If the base prefix, and the sign if any, is followed by a foreign
;;   digit, nothing matches.  The letters, digits, and underscores that
;;   follow are consumed.  #b|2, #b-|2, and #b2|1 match nothing.
;; - Otherwise, if the base prefix is not followed by a digit of the
;;   base, # is an ordinary symbol, and the rest is read as if # is not
;;   there.  #box|2 matches 2, and #xg|1 matches 1.
;;
;; The last rule differs from the C-style, in which 0xg|1 matches
;; nothing.  It is because # followed by letters is common outside of
;; Lisp, such as #box2 in CSS, and page.html#xref1 in a URL.
;;
;; 4.6. Going below zero
;;
;; If the + or - before the integer is demoted, the integer cannot
;; become negative.  1-|2 decremented by 3 would be 1--1, and that
;; would be read back as 1.  A `user-error' is signaled instead.
;;
;; If there is no + or - before the integer, nothing is demoted, and the
;; integer can become negative.  a|1 decremented by 2 is a-1, although
;; it is read back as 1.
;;
;; The sign of an Elisp-style non-decimal is never demoted, so it can
;; always become negative.  a#x|1 decremented by 2 is a#x-1.
;;
;; 4.7. Not supported
;;
;; - The Elisp-style radix prefix, such as #24r1k.  # is an ordinary
;;   symbol, and #24r1k is read as the decimals 24 and 1.
;; - An underscore right after the base prefix, such as 0x_ff, which is
;;   accepted by Python and Rust.  It matches nothing.
;; - A hexadecimal can swallow the beginning of a suffix which is made
;;   of a to f.  There is no way around that.

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

(rx-define my/thingatpt-rx-sign (in "-+"))

;; A run of digits, with underscores allowed between digits.
(rx-define my/thingatpt-rx-digits-with-underscore (digit)
  (seq digit (* (or (seq "_" digit) digit))))

;; The letters, digits, and underscores following an invalid integer.
(rx-define my/thingatpt-rx-tail (* (in "0-9a-zA-Z_")))

;; The integer regexps share the same groups.
;;
;; Group 1 is the integral part, which consists of group 2, 3, and 4.
;; In the C style, the order is group 2, 3, and 4.
;; In the Elisp style, the order is group 3, 2, and 4.
;; Group 2 is the sign of the integral part.
;; Group 3 is the base prefix.
;; Group 4 is the digits of the integral part.
;; Group 5 is the exponent part, which consists of group 6, and 7.
;; Group 6 is the sign of the exponent part.
;; Group 7 is the digits of the exponent part.
;; Group 8 is the part that makes the match invalid.
;; If it is not empty, the match must be rejected.

(defconst my/thingatpt-binary-integer-regexp
  (rx
   (group-n 1
     (group-n 2 (? my/thingatpt-rx-sign))
     (group-n 3 (or "0b" "0B"))
     (group-n 4 (my/thingatpt-rx-digits-with-underscore (in "01"))))
   (group-n 8 (? (in "2-9") my/thingatpt-rx-tail)))
  "A regular expression for binary integers such as 0b101.

It is invalid if it is followed by a digit that is not a binary digit.")

(defconst my/thingatpt-octal-integer-regexp
  (rx
   (group-n 1
     (group-n 2 (? my/thingatpt-rx-sign))
     (group-n 3 (or "0o" "0O"))
     (group-n 4 (my/thingatpt-rx-digits-with-underscore (in "0-7"))))
   (group-n 8 (? (in "89") my/thingatpt-rx-tail)))
  "A regular expression for octal integers such as 0o17.

It is invalid if it is followed by a digit that is not an octal digit.")

(defconst my/thingatpt-hexadecimal-integer-regexp
  (rx
   (group-n 1
     (group-n 2 (? my/thingatpt-rx-sign))
     (group-n 3 (or "0x" "0X"))
     (group-n 4 (my/thingatpt-rx-digits-with-underscore (in "0-9a-fA-F")))))
  "A regular expression for hexadecimal integers such as 0xff.")

(defconst my/thingatpt-bare-base-prefix-regexp
  (rx
   (? my/thingatpt-rx-sign)
   (group-n 8 (or "0b" "0B" "0o" "0O" "0x" "0X") my/thingatpt-rx-tail))
  "A regular expression for a base prefix that is not followed by a valid digit.

It is always invalid.")

(defconst my/thingatpt-elisp-binary-integer-regexp
  (rx
   (group-n 1
     (group-n 3 (or "#b" "#B"))
     (group-n 2 (? my/thingatpt-rx-sign))
     (group-n 4 (+ (in "01"))))
   (group-n 8 (? (in "2-9a-zA-Z") my/thingatpt-rx-tail)))
  "A regular expression for Elisp-style binary integers such as #b101.

It is invalid if it is followed by a letter,
or a digit that is not a binary digit.")

(defconst my/thingatpt-elisp-octal-integer-regexp
  (rx
   (group-n 1
     (group-n 3 (or "#o" "#O"))
     (group-n 2 (? my/thingatpt-rx-sign))
     (group-n 4 (+ (in "0-7"))))
   (group-n 8 (? (in "89a-zA-Z") my/thingatpt-rx-tail)))
  "A regular expression for Elisp-style octal integers such as #o17.

It is invalid if it is followed by a letter,
or a digit that is not an octal digit.")

(defconst my/thingatpt-elisp-hexadecimal-integer-regexp
  (rx
   (group-n 1
     (group-n 3 (or "#x" "#X"))
     (group-n 2 (? my/thingatpt-rx-sign))
     (group-n 4 (+ (in "0-9a-fA-F"))))
   (group-n 8 (? (in "g-zG-Z") my/thingatpt-rx-tail)))
  "A regular expression for Elisp-style hexadecimal integers such as #xff.

It is invalid if it is followed by a letter that is not a hexadecimal digit.")

(defconst my/thingatpt-elisp-foreign-digit-regexp
  (rx
   (or
    (seq (or "#b" "#B")
         (? my/thingatpt-rx-sign)
         (group-n 8 (in "2-9") my/thingatpt-rx-tail))
    (seq (or "#o" "#O")
         (? my/thingatpt-rx-sign)
         (group-n 8 (in "89") my/thingatpt-rx-tail))))
  "A regular expression for an Elisp-style base prefix that is followed by a foreign digit.

It is always invalid.")

(defconst my/thingatpt-decimal-integer-regexp
  (rx
   (group-n 1
     (group-n 2 (? my/thingatpt-rx-sign))
     (group-n 4 (my/thingatpt-rx-digits-with-underscore (in "0-9"))))
   (? (in "eE") (group-n 5
                  (group-n 6 (? my/thingatpt-rx-sign))
                  (group-n 7 (my/thingatpt-rx-digits-with-underscore (in "0-9"))))))
  "A regular expression for decimal integers such as 42, or 1e10.")

(defconst my/thingatpt-integer-regexp
  (rx
   (or
    (regexp my/thingatpt-binary-integer-regexp)
    (regexp my/thingatpt-octal-integer-regexp)
    (regexp my/thingatpt-hexadecimal-integer-regexp)
    ;; This must be after the above ones,
    ;; so that it matches only if there is no valid digit.
    ;; This must be before the decimal one,
    ;; so that 0x is not treated as the decimal integer 0.
    (regexp my/thingatpt-bare-base-prefix-regexp)
    (regexp my/thingatpt-elisp-binary-integer-regexp)
    (regexp my/thingatpt-elisp-octal-integer-regexp)
    (regexp my/thingatpt-elisp-hexadecimal-integer-regexp)
    ;; This must be after the above ones,
    ;; so that it matches only if there is no valid digit.
    (regexp my/thingatpt-elisp-foreign-digit-regexp)
    (regexp my/thingatpt-decimal-integer-regexp)))
  "A regular expression for integers.

If group 8 is not empty, the match must be rejected.
See `my/thingatpt-integer-match'.")

(defconst my/thingatpt-sign-demoting-regexp
  (rx (in "0-9a-zA-Z_)]}+-"))
  "A regular expression for a character that demotes the + or - after it.

A demoted + or - is not the sign of the integer after it.
For example, the - in 1-2 is not the sign of 2.")

;;;###autoload
(defun my/thingatpt-integer-match ()
  "Return non-nil if point is in or after an integer.

The return value is a plist with the following properties.

:style is the style of the integer, which is either the symbol `c',
or the symbol `elisp'.  See `my/thingatpt--base-prefix-to-style'.

:demoted is t if the + or - before the integer is demoted,
according to `my/thingatpt-sign-demoting-regexp'.
In that case, the + or - is not part of the match.
Only the sign of a C-style integer can be demoted.

Match data is set according to `my/thingatpt-integer-regexp'."
  (interactive)
  (when (and (my/thingatpt-point-in-or-after-regexp my/thingatpt-integer-regexp)
             (my/thingatpt--match-empty-p 8))
    (pcase (my/thingatpt--base-prefix-to-style
            (my/thingatpt--buffer-substring-no-properties-of-match 3))
      ;; The sign is after the base prefix, so it is never demoted.
      ('elisp
       (list :style 'elisp :demoted nil))
      ('c
       (let* ((char-before-sign (char-before (match-beginning 2)))
              (demoted (and (not (my/thingatpt--match-empty-p 2))
                            char-before-sign
                            (string-match-p my/thingatpt-sign-demoting-regexp
                                            (char-to-string char-before-sign))
                            t)))
         ;; Match again without the sign.
         (when demoted
           (save-excursion
             (goto-char (match-end 2))
             (looking-at my/thingatpt-integer-regexp)))
         ;; After demotion, the integer may begin after point.
         (when (>= (point) (match-beginning 0))
           (list :style 'c :demoted demoted)))))))

;;;###autoload
(defun my/thingatpt-integer-increment (count)
  "Increment integer at point with COUNT.

Always move point after the integer.

Signal an error if the result is negative,
and the + or - before the integer is demoted.
It is because the sign of the result would be demoted as well."
  (interactive "p")
  (when-let* ((match (my/thingatpt-integer-match)))
    (let* ((style (plist-get match :style))
           (demoted (plist-get match :demoted))
           (integral-digits-with-underscore (my/thingatpt--buffer-substring-no-properties-of-match 4))
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
        (let* ((result (my/thingatpt--increment style exponent-sign "" exponent-digits-with-underscore count))
               (exponent-beg (match-beginning 5)))
          (replace-region-contents
           (match-beginning 5)
           (match-end 5)
           result)
          ;; Move point to the end of the exponent part.
          (goto-char (+ exponent-beg (length result)))))
       ;; Otherwise, increment the integral part.
       (t
        (let* ((result (my/thingatpt--increment style integral-sign base-prefix integral-digits-with-underscore count))
               (integral-beg (match-beginning 1)))
          (when (and demoted (string-prefix-p "-" result))
            (user-error "Decrementing this sign-demoted integer to negative will introduce a superfluous sign"))
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
    ((or "0b" "0B" "#b" "#B") 2)
    ((or "0o" "0O" "#o" "#O") 8)
    ((or "0x" "0X" "#x" "#X") 16)
    (_ 10)))

;;;###autoload
(defun my/thingatpt--base-prefix-to-style (base-prefix)
  "Convert BASE-PREFIX to the style of the integer.

Return the symbol `elisp' if BASE-PREFIX is an Elisp-style base prefix.
The order is base prefix, sign, and digits, such as #x-10.

Otherwise, return the symbol `c'.
The order is sign, base prefix, and digits, such as -0x10.
A decimal integer has no base prefix, and it is in the C style."
  (pcase base-prefix
    ((or "#b" "#B" "#o" "#O" "#x" "#X") 'elisp)
    (_ 'c)))

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
(defun my/thingatpt--increment (style sign base-prefix digits-with-underscore count)
  "Increment DIGITS-WITH-UNDERSCORE whose sign is SIGN in base indicated by BASE-PREFIX with COUNT.

STYLE is a symbol returned by `my/thingatpt--base-prefix-to-style'.
It decides the order of the sign and the base prefix in the result.
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
    (pcase style
      ('c (format "%s%s%s" result-sign base-prefix (concat list)))
      ('elisp (format "%s%s%s" base-prefix result-sign (concat list)))
      (_ (error "Unknown style: %S" style)))))

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
