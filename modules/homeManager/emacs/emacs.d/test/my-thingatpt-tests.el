;;; my-thingatpt-tests.el --- my-thingatpt-tests.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ert)
(require 'my-thingatpt)

;;;; Helpers

(defvar my-thingatpt-tests--time-zone "UTC0"
  "The time zone rule in effect when running the tests.")

(defun my-thingatpt-tests--call (text fn &rest args)
  "Insert TEXT into a temporary buffer, and call FN with ARGS.

The character | in TEXT denotes point, and it is removed from the buffer.

The time zone is `my-thingatpt-tests--time-zone', and the time locale is C,
so that the result does not depend on the environment.

Return a cons cell of the return value of FN,
and the buffer contents with | inserted at point."
  (let ((original-time-zone (getenv "TZ"))
        (system-time-locale "C"))
    (unwind-protect
        (with-temp-buffer
          (set-time-zone-rule my-thingatpt-tests--time-zone)
          (insert text)
          (goto-char (point-min))
          (search-forward "|")
          (delete-char -1)
          (let ((value (apply fn args)))
            (insert "|")
            (cons value (buffer-string))))
      (set-time-zone-rule original-time-zone))))

(defun my-thingatpt-tests--edit (text fn &rest args)
  "Like `my-thingatpt-tests--call', but return the buffer contents only.

Use TEXT FN ARGS."
  (cdr (apply #'my-thingatpt-tests--call text fn args)))

(defun my-thingatpt-tests--value (text fn &rest args)
  "Like `my-thingatpt-tests--call', but return the return value of FN only.

Use TEXT FN ARGS."
  (car (apply #'my-thingatpt-tests--call text fn args)))

;;;; Org date

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-match ()
  ;; Point is in the date.
  (should (my-thingatpt-tests--value "|2006-01-02 Mon" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "2006-|01-02 Mon" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "2006-01-02 M|on" #'my/thingatpt-org-date-match))
  ;; Point is right after the date.
  (should (my-thingatpt-tests--value "2006-01-02 Mon|" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "<2006-01-02 Mon|>" #'my/thingatpt-org-date-match))
  ;; Point is outside of the date.
  (should-not (my-thingatpt-tests--value "| 2006-01-02 Mon" #'my/thingatpt-org-date-match))
  (should-not (my-thingatpt-tests--value "2006-01-02 Mon |" #'my/thingatpt-org-date-match))
  ;; Not an Org date.
  (should-not (my-thingatpt-tests--value "|2006-01-02" #'my/thingatpt-org-date-match))
  (should-not (my-thingatpt-tests--value "|2006-01-02 Monday" #'my/thingatpt-org-date-match))
  (should-not (my-thingatpt-tests--value "|2006-13-02 Mon" #'my/thingatpt-org-date-match))
  (should-not (my-thingatpt-tests--value "|2006-01-32 Mon" #'my/thingatpt-org-date-match))
  (should-not (my-thingatpt-tests--value "|12006-01-02 Mon" #'my/thingatpt-org-date-match)))

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-increment-day ()
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 Mon" #'my/thingatpt-org-date-increment 1)
    "2006-01-|03 Tue"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-0|2 Mon" #'my/thingatpt-org-date-increment 1)
    "2006-01-0|3 Tue"))
  ;; Point is in the day of week.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-02 Mo|n" #'my/thingatpt-org-date-increment 1)
    "2006-01-03 Tu|e"))
  ;; Point is right after the date.
  (should
   (equal
    (my-thingatpt-tests--edit "<2006-01-02 Mon|>" #'my/thingatpt-org-date-increment 1)
    "<2006-01-03 Tue|>"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 Mon" #'my/thingatpt-org-date-increment 7)
    "2006-01-|09 Mon"))
  ;; Carry to month.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|31 Tue" #'my/thingatpt-org-date-increment 1)
    "2006-02-|01 Wed"))
  ;; Carry to year.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-12-|31 Sun" #'my/thingatpt-org-date-increment 1)
    "2007-01-|01 Mon"))
  ;; Leap year.
  (should
   (equal
    (my-thingatpt-tests--edit "2024-02-|28 Wed" #'my/thingatpt-org-date-increment 1)
    "2024-02-|29 Thu"))
  (should
   (equal
    (my-thingatpt-tests--edit "2023-02-|28 Tue" #'my/thingatpt-org-date-increment 1)
    "2023-03-|01 Wed"))
  ;; Negative count.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 Mon" #'my/thingatpt-org-date-increment -2)
    "2005-12-|31 Sat")))

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-increment-month ()
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|01-02 Mon" #'my/thingatpt-org-date-increment 1)
    "2006-|02-02 Thu"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01|-02 Mon" #'my/thingatpt-org-date-increment 1)
    "2006-02|-02 Thu"))
  ;; Carry to year.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|12-02 Sat" #'my/thingatpt-org-date-increment 1)
    "2007-|01-02 Tue"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|01-02 Mon" #'my/thingatpt-org-date-increment 25)
    "2008-|02-02 Sat"))
  ;; Day is clamped.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|01-31 Tue" #'my/thingatpt-org-date-increment 1)
    "2006-|02-28 Tue"))
  (should
   (equal
    (my-thingatpt-tests--edit "2024-|01-31 Wed" #'my/thingatpt-org-date-increment 1)
    "2024-|02-29 Thu"))
  ;; Negative count.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|01-02 Mon" #'my/thingatpt-org-date-increment -1)
    "2005-|12-02 Fri")))

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-increment-year ()
  (should
   (equal
    (my-thingatpt-tests--edit "|2006-01-02 Mon" #'my/thingatpt-org-date-increment 1)
    "|2007-01-02 Tue"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006|-01-02 Mon" #'my/thingatpt-org-date-increment 1)
    "2007|-01-02 Tue"))
  (should
   (equal
    (my-thingatpt-tests--edit "|2006-01-02 Mon" #'my/thingatpt-org-date-increment 10)
    "|2016-01-02 Sat"))
  ;; Day is clamped.
  (should
   (equal
    (my-thingatpt-tests--edit "|2024-02-29 Thu" #'my/thingatpt-org-date-increment 1)
    "|2025-02-28 Fri"))
  ;; Negative count.
  (should
   (equal
    (my-thingatpt-tests--edit "|2006-01-02 Mon" #'my/thingatpt-org-date-increment -1)
    "|2005-01-02 Sun")))

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-increment-day-of-week ()
  ;; The day of week is corrected.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 Sun" #'my/thingatpt-org-date-increment 1)
    "2006-01-|03 Tue"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 Sun" #'my/thingatpt-org-date-increment 0)
    "2006-01-|02 Mon")))

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-increment-surrounding-text ()
  (should
   (equal
    (my-thingatpt-tests--edit "SCHEDULED: <2006-01-|02 Mon 15:04>" #'my/thingatpt-org-date-increment 1)
    "SCHEDULED: <2006-01-|03 Tue 15:04>"))
  ;; Only the date at point is edited.
  (should
   (equal
    (my-thingatpt-tests--edit "<2006-01-02 Mon>--<2006-01-|09 Mon>" #'my/thingatpt-org-date-increment 1)
    "<2006-01-02 Mon>--<2006-01-|10 Tue>"))
  (should
   (equal
    (my-thingatpt-tests--edit "<2006-01-|02 Mon>--<2006-01-09 Mon>" #'my/thingatpt-org-date-increment 1)
    "<2006-01-|03 Tue>--<2006-01-09 Mon>"))
  ;; Only the current line is searched.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-02 Mon\n2006-01-|02 Mon\n2006-01-02 Mon" #'my/thingatpt-org-date-increment 1)
    "2006-01-02 Mon\n2006-01-|03 Tue\n2006-01-02 Mon")))

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-increment-no-match ()
  (should
   (equal
    (my-thingatpt-tests--call "| 2006-01-02 Mon" #'my/thingatpt-org-date-increment 1)
    '(nil . "| 2006-01-02 Mon")))
  (should
   (equal
    (my-thingatpt-tests--call "2006-01-|02" #'my/thingatpt-org-date-increment 1)
    '(nil . "2006-01-|02"))))

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-increment-error ()
  ;; Year 0000 is not supported.
  (should-error (my-thingatpt-tests--edit "0000-01-|02 Mon" #'my/thingatpt-org-date-increment 1))
  ;; The date matches the regexp, but it is invalid.
  (should-error (my-thingatpt-tests--edit "2006-00-|02 Mon" #'my/thingatpt-org-date-increment 1))
  (should-error (my-thingatpt-tests--edit "2006-01-|00 Mon" #'my/thingatpt-org-date-increment 1))
  (should-error (my-thingatpt-tests--edit "2006-02-|31 Mon" #'my/thingatpt-org-date-increment 1))
  ;; Year must be <= 9999.
  (should-error (my-thingatpt-tests--edit "9999-12-|31 Fri" #'my/thingatpt-org-date-increment 1))
  (should-error (my-thingatpt-tests--edit "9999-|12-31 Fri" #'my/thingatpt-org-date-increment 1))
  (should-error (my-thingatpt-tests--edit "|9999-12-31 Fri" #'my/thingatpt-org-date-increment 1))
  ;; Year must be >= 0001.
  (should-error (my-thingatpt-tests--edit "0001-01-|01 Mon" #'my/thingatpt-org-date-increment -1))
  ;; The buffer is not changed on error.
  (with-temp-buffer
    (insert "9999-12-31 Fri")
    (goto-char 10)
    (should-error (my/thingatpt-org-date-increment 1))
    (should (equal (buffer-string) "9999-12-31 Fri"))
    (should (equal (point) 10))))

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-decrement ()
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 Mon" #'my/thingatpt-org-date-decrement 1)
    "2006-01-|01 Sun"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|01 Sun" #'my/thingatpt-org-date-decrement 1)
    "2005-12-|31 Sat"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|03-31 Fri" #'my/thingatpt-org-date-decrement 1)
    "2006-|02-28 Tue"))
  (should
   (equal
    (my-thingatpt-tests--edit "|2006-01-02 Mon" #'my/thingatpt-org-date-decrement 1)
    "|2005-01-02 Sun"))
  ;; Negative count.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 Mon" #'my/thingatpt-org-date-decrement -1)
    "2006-01-|03 Tue")))

;; FIXME: The date is off by one day in time zones behind UTC,
;; because `my/calendar-gregorian-to-org-string' and
;; `my/calendar-gregorian-iso8601-date-string' encode the date in UTC,
;; and then format it in the local time zone.
(ert-deftest my-thingatpt-tests-my/thingatpt-date-increment-time-zone-behind-utc ()
  :expected-result :failed
  (let ((my-thingatpt-tests--time-zone "XXX8"))
    (should
     (equal
      (my-thingatpt-tests--edit "2006-01-|02 Mon" #'my/thingatpt-org-date-increment 1)
      "2006-01-|03 Tue"))
    (should
     (equal
      (my-thingatpt-tests--edit "2006-01-|02" #'my/thingatpt-iso8601-date-increment 1)
      "2006-01-|03"))))

(ert-deftest my-thingatpt-tests-my/thingatpt-date-increment-time-zone-ahead-of-utc ()
  (let ((my-thingatpt-tests--time-zone "XXX-14"))
    (should
     (equal
      (my-thingatpt-tests--edit "2006-01-|02 Mon" #'my/thingatpt-org-date-increment 1)
      "2006-01-|03 Tue"))
    (should
     (equal
      (my-thingatpt-tests--edit "2006-01-|02" #'my/thingatpt-iso8601-date-increment 1)
      "2006-01-|03"))))

;;;; ISO8601 date

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-match ()
  ;; Point is in the date.
  (should (my-thingatpt-tests--value "|2006-01-02" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "2006-|01-02" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "2006-01-0|2" #'my/thingatpt-iso8601-date-match))
  ;; Point is right after the date.
  (should (my-thingatpt-tests--value "2006-01-02|" #'my/thingatpt-iso8601-date-match))
  ;; An Org date contains a ISO8601 date.
  (should (my-thingatpt-tests--value "2006-01-|02 Mon" #'my/thingatpt-iso8601-date-match))
  ;; Point is outside of the date.
  (should-not (my-thingatpt-tests--value "| 2006-01-02" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "2006-01-02 |" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "2006-01-02 M|on" #'my/thingatpt-iso8601-date-match))
  ;; The date must end at a word boundary.
  (should-not (my-thingatpt-tests--value "2006-01-|02T15:04:05Z" #'my/thingatpt-iso8601-date-match))
  ;; Not a ISO8601 date.
  (should-not (my-thingatpt-tests--value "|2006-1-2" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|2006-13-02" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|2006-01-32" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|12006-01-02" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|2006-01-021" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|20060102" #'my/thingatpt-iso8601-date-match)))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-increment-day ()
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02" #'my/thingatpt-iso8601-date-increment 1)
    "2006-01-|03"))
  ;; Point is right after the date.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-02|" #'my/thingatpt-iso8601-date-increment 1)
    "2006-01-03|"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02" #'my/thingatpt-iso8601-date-increment 30)
    "2006-02-|01"))
  ;; Carry to year.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-12-|31" #'my/thingatpt-iso8601-date-increment 1)
    "2007-01-|01"))
  ;; Leap year.
  (should
   (equal
    (my-thingatpt-tests--edit "2024-02-|28" #'my/thingatpt-iso8601-date-increment 1)
    "2024-02-|29"))
  (should
   (equal
    (my-thingatpt-tests--edit "2023-02-|28" #'my/thingatpt-iso8601-date-increment 1)
    "2023-03-|01"))
  ;; 1900 is not a leap year, while 2000 is.
  (should
   (equal
    (my-thingatpt-tests--edit "1900-02-|28" #'my/thingatpt-iso8601-date-increment 1)
    "1900-03-|01"))
  (should
   (equal
    (my-thingatpt-tests--edit "2000-02-|28" #'my/thingatpt-iso8601-date-increment 1)
    "2000-02-|29"))
  ;; Negative count.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02" #'my/thingatpt-iso8601-date-increment -2)
    "2005-12-|31")))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-increment-month ()
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|01-02" #'my/thingatpt-iso8601-date-increment 1)
    "2006-|02-02"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01|-02" #'my/thingatpt-iso8601-date-increment 1)
    "2006-02|-02"))
  ;; Carry to year.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|12-02" #'my/thingatpt-iso8601-date-increment 1)
    "2007-|01-02"))
  ;; Day is clamped.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|01-31" #'my/thingatpt-iso8601-date-increment 1)
    "2006-|02-28"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|03-31" #'my/thingatpt-iso8601-date-increment 1)
    "2006-|04-30"))
  ;; Negative count.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|01-02" #'my/thingatpt-iso8601-date-increment -13)
    "2004-|12-02")))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-increment-year ()
  (should
   (equal
    (my-thingatpt-tests--edit "|2006-01-02" #'my/thingatpt-iso8601-date-increment 1)
    "|2007-01-02"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006|-01-02" #'my/thingatpt-iso8601-date-increment 1)
    "2007|-01-02"))
  ;; Day is clamped.
  (should
   (equal
    (my-thingatpt-tests--edit "|2024-02-29" #'my/thingatpt-iso8601-date-increment 1)
    "|2025-02-28"))
  (should
   (equal
    (my-thingatpt-tests--edit "|2024-02-29" #'my/thingatpt-iso8601-date-increment 4)
    "|2028-02-29"))
  ;; Negative count.
  (should
   (equal
    (my-thingatpt-tests--edit "|2006-01-02" #'my/thingatpt-iso8601-date-increment -1)
    "|2005-01-02")))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-increment-boundary ()
  (should
   (equal
    (my-thingatpt-tests--edit "0001-01-|01" #'my/thingatpt-iso8601-date-increment 1)
    "0001-01-|02"))
  (should
   (equal
    (my-thingatpt-tests--edit "0001-01-|02" #'my/thingatpt-iso8601-date-increment -1)
    "0001-01-|01"))
  (should
   (equal
    (my-thingatpt-tests--edit "9999-12-|30" #'my/thingatpt-iso8601-date-increment 1)
    "9999-12-|31"))
  (should
   (equal
    (my-thingatpt-tests--edit "|9998-12-31" #'my/thingatpt-iso8601-date-increment 1)
    "|9999-12-31")))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-increment-surrounding-text ()
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 15:04:05" #'my/thingatpt-iso8601-date-increment 1)
    "2006-01-|03 15:04:05"))
  ;; The day of week of an Org date is left as is.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02 Mon" #'my/thingatpt-iso8601-date-increment 1)
    "2006-01-|03 Mon"))
  ;; Only the date at point is edited.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-02 2006-01-|09" #'my/thingatpt-iso8601-date-increment 1)
    "2006-01-02 2006-01-|10"))
  ;; Only the current line is searched.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-02\n2006-01-|02\n2006-01-02" #'my/thingatpt-iso8601-date-increment 1)
    "2006-01-02\n2006-01-|03\n2006-01-02")))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-increment-no-match ()
  (should
   (equal
    (my-thingatpt-tests--call "| 2006-01-02" #'my/thingatpt-iso8601-date-increment 1)
    '(nil . "| 2006-01-02")))
  (should
   (equal
    (my-thingatpt-tests--call "2006-1-|2" #'my/thingatpt-iso8601-date-increment 1)
    '(nil . "2006-1-|2"))))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-increment-error ()
  ;; Year 0000 is not supported.
  (should-error (my-thingatpt-tests--edit "0000-01-|02" #'my/thingatpt-iso8601-date-increment 1))
  ;; The date matches the regexp, but it is invalid.
  (should-error (my-thingatpt-tests--edit "2006-00-|02" #'my/thingatpt-iso8601-date-increment 1))
  (should-error (my-thingatpt-tests--edit "2006-01-|00" #'my/thingatpt-iso8601-date-increment 1))
  (should-error (my-thingatpt-tests--edit "2006-02-|31" #'my/thingatpt-iso8601-date-increment 1))
  (should-error (my-thingatpt-tests--edit "2023-02-|29" #'my/thingatpt-iso8601-date-increment 1))
  ;; Year must be <= 9999.
  (should-error (my-thingatpt-tests--edit "9999-12-|31" #'my/thingatpt-iso8601-date-increment 1))
  (should-error (my-thingatpt-tests--edit "9999-|12-31" #'my/thingatpt-iso8601-date-increment 1))
  (should-error (my-thingatpt-tests--edit "|9999-12-31" #'my/thingatpt-iso8601-date-increment 1))
  ;; Year must be >= 0001.
  (should-error (my-thingatpt-tests--edit "0001-01-|01" #'my/thingatpt-iso8601-date-increment -1))
  ;; The buffer is not changed on error.
  (with-temp-buffer
    (insert "9999-12-31")
    (goto-char 10)
    (should-error (my/thingatpt-iso8601-date-increment 1))
    (should (equal (buffer-string) "9999-12-31"))
    (should (equal (point) 10))))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-decrement ()
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02" #'my/thingatpt-iso8601-date-decrement 1)
    "2006-01-|01"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|01" #'my/thingatpt-iso8601-date-decrement 1)
    "2005-12-|31"))
  (should
   (equal
    (my-thingatpt-tests--edit "2006-|03-31" #'my/thingatpt-iso8601-date-decrement 1)
    "2006-|02-28"))
  (should
   (equal
    (my-thingatpt-tests--edit "|2006-01-02" #'my/thingatpt-iso8601-date-decrement 1)
    "|2005-01-02"))
  ;; Negative count.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02" #'my/thingatpt-iso8601-date-decrement -1)
    "2006-01-|03")))

;;;; Integer

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-match ()
  ;; Point is in the integer.
  (should (my-thingatpt-tests--value "|42" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "4|2" #'my/thingatpt-integer-match))
  ;; Point is right after the integer.
  (should (my-thingatpt-tests--value "42|" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "(42|)" #'my/thingatpt-integer-match))
  ;; Sign.
  (should (my-thingatpt-tests--value "|-42" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "|+42" #'my/thingatpt-integer-match))
  ;; Base prefix.
  (should (my-thingatpt-tests--value "|0b101" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "|#b101" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "|0o17" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "|#o17" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "|0xff" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "|#xff" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "0|xff" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "0xf|f" #'my/thingatpt-integer-match))
  ;; Underscore.
  (should (my-thingatpt-tests--value "1_|000" #'my/thingatpt-integer-match))
  ;; Exponent.
  (should (my-thingatpt-tests--value "1e|10" #'my/thingatpt-integer-match))
  ;; Point is outside of the integer.
  (should-not (my-thingatpt-tests--value "| 42" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "42 |" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "|foo" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "|" #'my/thingatpt-integer-match))
  ;; Only the current line is searched.
  (should-not (my-thingatpt-tests--value "42\n|\n42" #'my/thingatpt-integer-match)))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-decimal ()
  (should (equal (my-thingatpt-tests--edit "|0" #'my/thingatpt-integer-increment 1) "1|"))
  (should (equal (my-thingatpt-tests--edit "|42" #'my/thingatpt-integer-increment 1) "43|"))
  (should (equal (my-thingatpt-tests--edit "4|2" #'my/thingatpt-integer-increment 1) "43|"))
  (should (equal (my-thingatpt-tests--edit "42|" #'my/thingatpt-integer-increment 1) "43|"))
  (should (equal (my-thingatpt-tests--edit "|42" #'my/thingatpt-integer-increment 10) "52|"))
  (should (equal (my-thingatpt-tests--edit "|42" #'my/thingatpt-integer-increment 0) "42|"))
  ;; The number of digits changes.
  (should (equal (my-thingatpt-tests--edit "|9" #'my/thingatpt-integer-increment 1) "10|"))
  (should (equal (my-thingatpt-tests--edit "|99" #'my/thingatpt-integer-increment 1) "100|"))
  (should (equal (my-thingatpt-tests--edit "|10" #'my/thingatpt-integer-increment -1) "9|"))
  ;; Negative count.
  (should (equal (my-thingatpt-tests--edit "|42" #'my/thingatpt-integer-increment -1) "41|"))
  (should (equal (my-thingatpt-tests--edit "|42" #'my/thingatpt-integer-increment -42) "0|"))
  ;; Bignum.
  (should
   (equal
    (my-thingatpt-tests--edit "|99999999999999999999999999999999" #'my/thingatpt-integer-increment 1)
    "100000000000000000000000000000000|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-sign ()
  ;; The result becomes negative.
  (should (equal (my-thingatpt-tests--edit "|0" #'my/thingatpt-integer-increment -1) "-1|"))
  (should (equal (my-thingatpt-tests--edit "|1" #'my/thingatpt-integer-increment -3) "-2|"))
  ;; The result becomes non-negative.
  (should (equal (my-thingatpt-tests--edit "|-1" #'my/thingatpt-integer-increment 1) "0|"))
  (should (equal (my-thingatpt-tests--edit "|-1" #'my/thingatpt-integer-increment 3) "2|"))
  ;; The result stays negative.
  (should (equal (my-thingatpt-tests--edit "|-42" #'my/thingatpt-integer-increment 1) "-41|"))
  (should (equal (my-thingatpt-tests--edit "-4|2" #'my/thingatpt-integer-increment 1) "-41|"))
  (should (equal (my-thingatpt-tests--edit "|-42" #'my/thingatpt-integer-increment -1) "-43|"))
  ;; The plus sign is kept unless the result is negative.
  (should (equal (my-thingatpt-tests--edit "|+42" #'my/thingatpt-integer-increment 1) "+43|"))
  (should (equal (my-thingatpt-tests--edit "|+1" #'my/thingatpt-integer-increment -1) "+0|"))
  (should (equal (my-thingatpt-tests--edit "|+1" #'my/thingatpt-integer-increment -2) "-1|"))
  (should (equal (my-thingatpt-tests--edit "|-0" #'my/thingatpt-integer-increment 0) "0|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-binary ()
  (should (equal (my-thingatpt-tests--edit "|0b101" #'my/thingatpt-integer-increment 1) "0b110|"))
  (should (equal (my-thingatpt-tests--edit "|0B101" #'my/thingatpt-integer-increment 1) "0B110|"))
  (should (equal (my-thingatpt-tests--edit "|#b101" #'my/thingatpt-integer-increment 1) "#b110|"))
  (should (equal (my-thingatpt-tests--edit "|#B101" #'my/thingatpt-integer-increment 1) "#B110|"))
  (should (equal (my-thingatpt-tests--edit "|0b111" #'my/thingatpt-integer-increment 1) "0b1000|"))
  (should (equal (my-thingatpt-tests--edit "|0b101" #'my/thingatpt-integer-increment -1) "0b100|"))
  (should (equal (my-thingatpt-tests--edit "|0b0" #'my/thingatpt-integer-increment -1) "-0b1|"))
  (should (equal (my-thingatpt-tests--edit "|-0b1" #'my/thingatpt-integer-increment 3) "0b10|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-octal ()
  (should (equal (my-thingatpt-tests--edit "|0o17" #'my/thingatpt-integer-increment 1) "0o20|"))
  (should (equal (my-thingatpt-tests--edit "|0O17" #'my/thingatpt-integer-increment 1) "0O20|"))
  (should (equal (my-thingatpt-tests--edit "|#o17" #'my/thingatpt-integer-increment 1) "#o20|"))
  (should (equal (my-thingatpt-tests--edit "|#O17" #'my/thingatpt-integer-increment 1) "#O20|"))
  (should (equal (my-thingatpt-tests--edit "|0o777" #'my/thingatpt-integer-increment 1) "0o1000|"))
  (should (equal (my-thingatpt-tests--edit "|0o20" #'my/thingatpt-integer-increment -1) "0o17|"))
  (should (equal (my-thingatpt-tests--edit "|0o0" #'my/thingatpt-integer-increment -1) "-0o1|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-hexadecimal ()
  (should (equal (my-thingatpt-tests--edit "|0xfe" #'my/thingatpt-integer-increment 1) "0xff|"))
  (should (equal (my-thingatpt-tests--edit "|0Xfe" #'my/thingatpt-integer-increment 1) "0Xff|"))
  (should (equal (my-thingatpt-tests--edit "|#xfe" #'my/thingatpt-integer-increment 1) "#xff|"))
  (should (equal (my-thingatpt-tests--edit "|#Xfe" #'my/thingatpt-integer-increment 1) "#Xff|"))
  (should (equal (my-thingatpt-tests--edit "|0xff" #'my/thingatpt-integer-increment 1) "0x100|"))
  (should (equal (my-thingatpt-tests--edit "|0x9" #'my/thingatpt-integer-increment 1) "0xa|"))
  (should (equal (my-thingatpt-tests--edit "|0x100" #'my/thingatpt-integer-increment -1) "0xff|"))
  (should (equal (my-thingatpt-tests--edit "|0x0" #'my/thingatpt-integer-increment -1) "-0x1|"))
  ;; Point is in the base prefix.
  (should (equal (my-thingatpt-tests--edit "0|xfe" #'my/thingatpt-integer-increment 1) "0xff|"))
  ;; The digits are always in lowercase.
  (should (equal (my-thingatpt-tests--edit "|0xFE" #'my/thingatpt-integer-increment 1) "0xff|"))
  ;; e in a hexadecimal integer is not an exponent indicator.
  (should (equal (my-thingatpt-tests--edit "|0x1e3" #'my/thingatpt-integer-increment 1) "0x1e4|"))
  (should (equal (my-thingatpt-tests--edit "0x1e|3" #'my/thingatpt-integer-increment 1) "0x1e4|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-underscore ()
  (should (equal (my-thingatpt-tests--edit "|1_000" #'my/thingatpt-integer-increment 1) "1_001|"))
  (should (equal (my-thingatpt-tests--edit "|1_000_000" #'my/thingatpt-integer-increment 1) "1_000_001|"))
  (should (equal (my-thingatpt-tests--edit "|0xff_ff" #'my/thingatpt-integer-increment -1) "0xff_fe|"))
  (should (equal (my-thingatpt-tests--edit "|0b1111_0000" #'my/thingatpt-integer-increment 1) "0b1111_0001|"))
  ;; The number of digits increases.
  (should (equal (my-thingatpt-tests--edit "|9_999" #'my/thingatpt-integer-increment 1) "10_000|"))
  (should (equal (my-thingatpt-tests--edit "|999_999" #'my/thingatpt-integer-increment 1) "1000_000|"))
  ;; The number of digits decreases.
  (should (equal (my-thingatpt-tests--edit "|10_000" #'my/thingatpt-integer-increment -1) "9_999|"))
  (should (equal (my-thingatpt-tests--edit "|100_000" #'my/thingatpt-integer-increment -1) "99_999|"))
  ;; Sign.
  (should (equal (my-thingatpt-tests--edit "|-1_000" #'my/thingatpt-integer-increment -1) "-1_001|"))
  (should (equal (my-thingatpt-tests--edit "|-9_999" #'my/thingatpt-integer-increment -1) "-10_000|")))

;; Leading underscores are dropped when the number of digits decreases.
(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-leading-underscore ()
  (should (equal (my-thingatpt-tests--edit "|1_000" #'my/thingatpt-integer-increment -1) "999|"))
  (should (equal (my-thingatpt-tests--edit "|1_000_000" #'my/thingatpt-integer-increment -1) "999_999|"))
  (should (equal (my-thingatpt-tests--edit "|-1_000" #'my/thingatpt-integer-increment 1) "-999|"))
  (should (equal (my-thingatpt-tests--edit "|0x1_00" #'my/thingatpt-integer-increment -1) "0xff|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-exponent ()
  ;; Point is in the integral part.
  (should (equal (my-thingatpt-tests--edit "|1e10" #'my/thingatpt-integer-increment 1) "2|e10"))
  (should (equal (my-thingatpt-tests--edit "1|e10" #'my/thingatpt-integer-increment 1) "2|e10"))
  (should (equal (my-thingatpt-tests--edit "|9e10" #'my/thingatpt-integer-increment 1) "10|e10"))
  (should (equal (my-thingatpt-tests--edit "|-1e10" #'my/thingatpt-integer-increment 2) "1|e10"))
  ;; Point is in the exponent part.
  (should (equal (my-thingatpt-tests--edit "1e|10" #'my/thingatpt-integer-increment 1) "1e11|"))
  (should (equal (my-thingatpt-tests--edit "1e1|0" #'my/thingatpt-integer-increment 1) "1e11|"))
  (should (equal (my-thingatpt-tests--edit "1e10|" #'my/thingatpt-integer-increment 1) "1e11|"))
  (should (equal (my-thingatpt-tests--edit "1E|10" #'my/thingatpt-integer-increment 1) "1E11|"))
  (should (equal (my-thingatpt-tests--edit "1e|99" #'my/thingatpt-integer-increment 1) "1e100|"))
  ;; Sign of the exponent part.
  (should (equal (my-thingatpt-tests--edit "1e|-10" #'my/thingatpt-integer-increment 1) "1e-9|"))
  (should (equal (my-thingatpt-tests--edit "1e-1|0" #'my/thingatpt-integer-increment 1) "1e-9|"))
  (should (equal (my-thingatpt-tests--edit "1e|+10" #'my/thingatpt-integer-increment 1) "1e+11|"))
  (should (equal (my-thingatpt-tests--edit "1e|0" #'my/thingatpt-integer-increment -1) "1e-1|"))
  (should (equal (my-thingatpt-tests--edit "1e|-1" #'my/thingatpt-integer-increment 1) "1e0|"))
  ;; The integral part is left as is.
  (should (equal (my-thingatpt-tests--edit "-1_000e|10" #'my/thingatpt-integer-increment 1) "-1_000e11|"))
  ;; Underscore in the exponent part.
  (should (equal (my-thingatpt-tests--edit "1e|1_000" #'my/thingatpt-integer-increment 1) "1e1_001|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-surrounding-text ()
  (should (equal (my-thingatpt-tests--edit "foo |42 bar" #'my/thingatpt-integer-increment 1) "foo 43| bar"))
  (should (equal (my-thingatpt-tests--edit "(|42)" #'my/thingatpt-integer-increment 1) "(43|)"))
  (should (equal (my-thingatpt-tests--edit "x = |42;" #'my/thingatpt-integer-increment 1) "x = 43|;"))
  ;; Only the integer at point is edited.
  (should (equal (my-thingatpt-tests--edit "1 |2 3" #'my/thingatpt-integer-increment 1) "1 3| 3"))
  (should (equal (my-thingatpt-tests--edit "1 2 |3" #'my/thingatpt-integer-increment 1) "1 2 4|"))
  (should (equal (my-thingatpt-tests--edit "[1, 2|, 3]" #'my/thingatpt-integer-increment 1) "[1, 3|, 3]"))
  ;; Only the current line is searched.
  (should (equal (my-thingatpt-tests--edit "1\n|2\n3" #'my/thingatpt-integer-increment 1) "1\n3|\n3")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-no-match ()
  (should
   (equal
    (my-thingatpt-tests--call "| 42" #'my/thingatpt-integer-increment 1)
    '(nil . "| 42")))
  (should
   (equal
    (my-thingatpt-tests--call "42 |" #'my/thingatpt-integer-increment 1)
    '(nil . "42 |")))
  (should
   (equal
    (my-thingatpt-tests--call "some|thing" #'my/thingatpt-integer-increment 1)
    '(nil . "some|thing"))))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-repeat ()
  ;; The command can be repeated because point is moved after the integer.
  (with-temp-buffer
    (insert "x = 8;")
    (goto-char 5)
    (dotimes (_ 3)
      (my/thingatpt-integer-increment 1))
    (should (equal (buffer-string) "x = 11;"))
    (dotimes (_ 13)
      (my/thingatpt-integer-decrement 1))
    (should (equal (buffer-string) "x = -2;"))))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-decrement ()
  (should (equal (my-thingatpt-tests--edit "|42" #'my/thingatpt-integer-decrement 1) "41|"))
  (should (equal (my-thingatpt-tests--edit "|0" #'my/thingatpt-integer-decrement 1) "-1|"))
  (should (equal (my-thingatpt-tests--edit "|-1" #'my/thingatpt-integer-decrement 1) "-2|"))
  (should (equal (my-thingatpt-tests--edit "|100" #'my/thingatpt-integer-decrement 1) "99|"))
  (should (equal (my-thingatpt-tests--edit "|0x10" #'my/thingatpt-integer-decrement 1) "0xf|"))
  (should (equal (my-thingatpt-tests--edit "|1_001" #'my/thingatpt-integer-decrement 1) "1_000|"))
  (should (equal (my-thingatpt-tests--edit "1e|10" #'my/thingatpt-integer-decrement 1) "1e9|"))
  ;; Negative count.
  (should (equal (my-thingatpt-tests--edit "|42" #'my/thingatpt-integer-decrement -1) "43|")))

;;;; Helpers

(ert-deftest my-thingatpt-tests-my/thingatpt--buffer-substring-no-properties-of-match ()
  (with-temp-buffer
    (insert (propertize "foo" 'face 'bold) "42")
    (goto-char (point-min))
    (should (re-search-forward (rx (group-n 1 (+ alpha)) (group-n 2 (+ digit)) (? (group-n 3 "!"))) nil t))
    (let ((whole (my/thingatpt--buffer-substring-no-properties-of-match 0))
          (group-1 (my/thingatpt--buffer-substring-no-properties-of-match 1)))
      (should (equal whole "foo42"))
      (should (equal group-1 "foo"))
      (should-not (text-properties-at 0 group-1)))
    (should (equal (my/thingatpt--buffer-substring-no-properties-of-match 2) "42"))
    ;; The group does not participate in the match.
    (should (equal (my/thingatpt--buffer-substring-no-properties-of-match 3) ""))
    ;; The group does not exist.
    (should (equal (my/thingatpt--buffer-substring-no-properties-of-match 4) ""))))

(ert-deftest my-thingatpt-tests-my/thingatpt-point-in-or-after-regexp ()
  (let ((regexp (rx (+ digit))))
    ;; Point is at the beginning of the match.
    (should (my-thingatpt-tests--value "foo |123 bar" #'my/thingatpt-point-in-or-after-regexp regexp))
    ;; Point is in the match.
    (should (my-thingatpt-tests--value "foo 1|23 bar" #'my/thingatpt-point-in-or-after-regexp regexp))
    ;; Point is right after the match.
    (should (my-thingatpt-tests--value "foo 123| bar" #'my/thingatpt-point-in-or-after-regexp regexp))
    ;; Point is before the match.
    (should-not (my-thingatpt-tests--value "foo| 123 bar" #'my/thingatpt-point-in-or-after-regexp regexp))
    ;; Point is after the match.
    (should-not (my-thingatpt-tests--value "foo 123 |bar" #'my/thingatpt-point-in-or-after-regexp regexp))
    (should-not (my-thingatpt-tests--value "foo 123 bar|" #'my/thingatpt-point-in-or-after-regexp regexp))
    ;; No match in the buffer.
    (should-not (my-thingatpt-tests--value "foo| bar" #'my/thingatpt-point-in-or-after-regexp regexp))
    (should-not (my-thingatpt-tests--value "|" #'my/thingatpt-point-in-or-after-regexp regexp))
    ;; Only the current line is searched.
    (should-not (my-thingatpt-tests--value "123\n|\n123" #'my/thingatpt-point-in-or-after-regexp regexp))
    (should-not (my-thingatpt-tests--value "123\n|foo" #'my/thingatpt-point-in-or-after-regexp regexp))
    (should-not (my-thingatpt-tests--value "foo|\n123" #'my/thingatpt-point-in-or-after-regexp regexp))
    (should (my-thingatpt-tests--value "123\n45|6\n789" #'my/thingatpt-point-in-or-after-regexp regexp))))

(ert-deftest my-thingatpt-tests-my/thingatpt-point-in-or-after-regexp-return-value ()
  ;; The return value is the end of the match.
  (should
   (equal
    (my-thingatpt-tests--value "foo 1|23 bar" #'my/thingatpt-point-in-or-after-regexp (rx (+ digit)))
    8))
  (should
   (equal
    (my-thingatpt-tests--value "foo 123| bar" #'my/thingatpt-point-in-or-after-regexp (rx (+ digit)))
    8)))

(ert-deftest my-thingatpt-tests-my/thingatpt-point-in-or-after-regexp-point ()
  ;; Point is not moved.
  (should
   (equal
    (my-thingatpt-tests--edit "foo 1|23 bar" #'my/thingatpt-point-in-or-after-regexp (rx (+ digit)))
    "foo 1|23 bar")))

(ert-deftest my-thingatpt-tests-my/thingatpt-point-in-or-after-regexp-match-data ()
  (with-temp-buffer
    (insert "foo 123 bar456 baz")
    ;; Point is in 456.
    (goto-char 13)
    (should (my/thingatpt-point-in-or-after-regexp (rx (group-n 1 (+ alpha)) (group-n 2 (+ digit)))))
    (should (equal (match-string 0) "bar456"))
    (should (equal (match-string 1) "bar"))
    (should (equal (match-string 2) "456"))
    (should (equal (match-beginning 0) 9))
    (should (equal (match-end 0) 15))))

(ert-deftest my-thingatpt-tests-my/thingatpt-point-in-or-after-regexp-multiple-matches ()
  (let ((regexp (rx (+ digit))))
    ;; The match at point is used, not the first match in the line.
    (with-temp-buffer
      (insert "1 22 333")
      (goto-char 4)
      (should (my/thingatpt-point-in-or-after-regexp regexp))
      (should (equal (match-string 0) "22"))
      (goto-char (point-max))
      (should (my/thingatpt-point-in-or-after-regexp regexp))
      (should (equal (match-string 0) "333"))
      (goto-char (point-min))
      (should (my/thingatpt-point-in-or-after-regexp regexp))
      (should (equal (match-string 0) "1")))
    ;; Point is between matches.
    (should-not (my-thingatpt-tests--value "1  |  22" #'my/thingatpt-point-in-or-after-regexp regexp))))

(ert-deftest my-thingatpt-tests-my/thingatpt-point-in-or-after-regexp-empty-match ()
  ;; A regexp that matches an empty string does not cause an infinite loop.
  (let ((regexp (rx (* digit))))
    (should (my-thingatpt-tests--value "foo 1|23 bar" #'my/thingatpt-point-in-or-after-regexp regexp))
    (should (my-thingatpt-tests--value "foo| bar" #'my/thingatpt-point-in-or-after-regexp regexp))
    (should (my-thingatpt-tests--value "foo bar|" #'my/thingatpt-point-in-or-after-regexp regexp))
    (should (my-thingatpt-tests--value "|" #'my/thingatpt-point-in-or-after-regexp regexp))))

(ert-deftest my-thingatpt-tests-my/thingatpt--increment ()
  ;; Decimal.
  (should (equal (my/thingatpt--increment "" "" "0" 1) "1"))
  (should (equal (my/thingatpt--increment "" "" "42" 1) "43"))
  (should (equal (my/thingatpt--increment "" "" "42" 0) "42"))
  (should (equal (my/thingatpt--increment "" "" "42" -1) "41"))
  (should (equal (my/thingatpt--increment "" "" "99" 1) "100"))
  (should (equal (my/thingatpt--increment "" "" "100" -1) "99"))
  ;; Sign.
  (should (equal (my/thingatpt--increment "" "" "0" -1) "-1"))
  (should (equal (my/thingatpt--increment "-" "" "1" 1) "0"))
  (should (equal (my/thingatpt--increment "-" "" "42" 1) "-41"))
  (should (equal (my/thingatpt--increment "-" "" "42" -1) "-43"))
  (should (equal (my/thingatpt--increment "-" "" "1" 2) "1"))
  (should (equal (my/thingatpt--increment "+" "" "42" 1) "+43"))
  (should (equal (my/thingatpt--increment "+" "" "1" -1) "+0"))
  (should (equal (my/thingatpt--increment "+" "" "1" -2) "-1"))
  ;; Base prefix.
  (should (equal (my/thingatpt--increment "" "0b" "101" 1) "0b110"))
  (should (equal (my/thingatpt--increment "" "0o" "17" 1) "0o20"))
  (should (equal (my/thingatpt--increment "" "0x" "ff" 1) "0x100"))
  (should (equal (my/thingatpt--increment "" "0x" "FF" -1) "0xfe"))
  (should (equal (my/thingatpt--increment "" "#x" "9" 1) "#xa"))
  (should (equal (my/thingatpt--increment "" "0x" "0" -1) "-0x1"))
  (should (equal (my/thingatpt--increment "-" "0x" "10" 1) "-0xf"))
  ;; Leading zeros are not kept.
  (should (equal (my/thingatpt--increment "" "" "007" 1) "8"))
  ;; Underscore.
  (should (equal (my/thingatpt--increment "" "" "1_000" 1) "1_001"))
  (should (equal (my/thingatpt--increment "" "" "1_000" -1) "999"))
  (should (equal (my/thingatpt--increment "" "" "1_000_000" 1) "1_000_001"))
  (should (equal (my/thingatpt--increment "" "" "1_000_000" -1) "999_999"))
  (should (equal (my/thingatpt--increment "" "" "1_0_0_0" 1) "1_0_0_1"))
  (should (equal (my/thingatpt--increment "" "" "1_0_0_0" -1) "9_9_9"))
  (should (equal (my/thingatpt--increment "" "" "9_999" 1) "10_000"))
  (should (equal (my/thingatpt--increment "" "" "10_000" -1) "9_999"))
  (should (equal (my/thingatpt--increment "" "0x" "ff_ff" 1) "0x100_00"))
  (should (equal (my/thingatpt--increment "-" "" "1_000" -1) "-1_001")))

(provide 'my-thingatpt-tests)
;;; my-thingatpt-tests.el ends here
