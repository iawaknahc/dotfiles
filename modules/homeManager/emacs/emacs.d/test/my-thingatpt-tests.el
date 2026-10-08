;;; my-thingatpt-tests.el --- my-thingatpt-tests.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ert)
(require 'my-thingatpt)

;;;; Helpers

(defvar my-thingatpt-tests--time-zone "UTC"
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

(defun my-thingatpt-tests--match-string (regexp string group)
  "Return match group GROUP if REGEXP matches at the beginning of STRING."
  (when (string-match (rx string-start (regexp regexp)) string)
    (match-string group string)))

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

(ert-deftest my-thingatpt-tests-my/thingatpt-org-date-match-neighbor ()
  ;; A digit before the date rejects it.
  (should-not (my-thingatpt-tests--value "1|2006-01-02 Mon" #'my/thingatpt-org-date-match))
  (should-not (my-thingatpt-tests--value "12006-01-02 Mon|" #'my/thingatpt-org-date-match))
  ;; A letter after the date rejects it.
  (should-not (my-thingatpt-tests--value "2|006-01-02 Monday" #'my/thingatpt-org-date-match))
  (should-not (my-thingatpt-tests--value "2006-01-02 Mon|day" #'my/thingatpt-org-date-match))
  ;; Any other neighbor does not.
  (should (my-thingatpt-tests--value "+2|006-01-02 Mon" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "-2|006-01-02 Mon" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "<2|006-01-02 Mon>" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "[2|006-01-02 Mon]" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "a2|006-01-02 Mon" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "log_2|006-01-02 Mon" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "2|006-01-02 Mon1" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "2|006-01-02 Mon_" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "2|006-01-02 Mon." #'my/thingatpt-org-date-match))
  ;; The search continues after a rejected date.
  (should (my-thingatpt-tests--value "12006-01-02 Mon 2|006-01-02 Mon" #'my/thingatpt-org-date-match))
  (should (my-thingatpt-tests--value "2006-01-02 Monday 2|006-01-02 Mon" #'my/thingatpt-org-date-match)))

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
    '(nil . "2006-01-|02")))
  ;; The date is rejected because of its neighbor.
  (should
   (equal
    (my-thingatpt-tests--call "1|2006-01-02 Mon" #'my/thingatpt-org-date-increment 1)
    '(nil . "1|2006-01-02 Mon")))
  (should
   (equal
    (my-thingatpt-tests--call "2006-01-|02 Monday" #'my/thingatpt-org-date-increment 1)
    '(nil . "2006-01-|02 Monday"))))

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

(ert-deftest my-thingatpt-tests-my/thingatpt-date-increment-time-zone-behind-utc ()
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
  ;; Not a ISO8601 date.
  (should-not (my-thingatpt-tests--value "|2006-1-2" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|2006-13-02" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|2006-01-32" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|12006-01-02" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|2006-01-021" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "|20060102" #'my/thingatpt-iso8601-date-match)))

(ert-deftest my-thingatpt-tests-my/thingatpt-iso8601-date-match-neighbor ()
  ;; A digit before the date rejects it.
  (should-not (my-thingatpt-tests--value "1|2006-01-02" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "12006-01-02|" #'my/thingatpt-iso8601-date-match))
  ;; A digit after the date rejects it.
  (should-not (my-thingatpt-tests--value "2|006-01-023" #'my/thingatpt-iso8601-date-match))
  (should-not (my-thingatpt-tests--value "2006-01-02|3" #'my/thingatpt-iso8601-date-match))
  ;; Any other neighbor does not.
  (should (my-thingatpt-tests--value "+2|006-01-02" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "-2|006-01-02" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "<2|006-01-02>" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "a2|006-01-02" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "log_2|006-01-02" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "2006-01-|02T15:04:05Z" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "2|006-01-02_notes.md" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "2|006-01-02-draft" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "2|006-01-02+08:00" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "2|006-01-02." #'my/thingatpt-iso8601-date-match))
  ;; The search continues after a rejected date.
  (should (my-thingatpt-tests--value "12006-01-02 2|006-01-02" #'my/thingatpt-iso8601-date-match))
  (should (my-thingatpt-tests--value "2006-01-023 2|006-01-02" #'my/thingatpt-iso8601-date-match))
  ;; A rejected date is consumed as a whole.
  ;; 0203-04-05 is not a date because 2006-01-0203 is consumed.
  (should-not (my-thingatpt-tests--value "2006-01-0203-04-|05" #'my/thingatpt-iso8601-date-match)))

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
  ;; The time of a timestamp is left as is.
  (should
   (equal
    (my-thingatpt-tests--edit "2006-01-|02T15:04:05Z" #'my/thingatpt-iso8601-date-increment 1)
    "2006-01-|03T15:04:05Z"))
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
    '(nil . "2006-1-|2")))
  ;; The date is rejected because of its neighbor.
  (should
   (equal
    (my-thingatpt-tests--call "1|2006-01-02" #'my/thingatpt-iso8601-date-increment 1)
    '(nil . "1|2006-01-02")))
  (should
   (equal
    (my-thingatpt-tests--call "2006-01-|023" #'my/thingatpt-iso8601-date-increment 1)
    '(nil . "2006-01-|023"))))

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
  (should (my-thingatpt-tests--value "|0o17" #'my/thingatpt-integer-match))
  (should (my-thingatpt-tests--value "|0xff" #'my/thingatpt-integer-match))
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

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-match-return-value ()
  (should (eq (my-thingatpt-tests--value "|foo" #'my/thingatpt-integer-match) nil))
  (should (eq (my-thingatpt-tests--value "|42" #'my/thingatpt-integer-match) t))
  (should (eq (my-thingatpt-tests--value "|-42" #'my/thingatpt-integer-match) t))
  (should (eq (my-thingatpt-tests--value "1-|2" #'my/thingatpt-integer-match) 'demoted)))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-match-sign-demoted ()
  ;; A digit.
  (should (eq (my-thingatpt-tests--value "1-|2" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "1+|2" #'my/thingatpt-integer-match) 'demoted))
  ;; A letter.
  (should (eq (my-thingatpt-tests--value "a-|1" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "a+|1" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "Z-|1" #'my/thingatpt-integer-match) 'demoted))
  ;; An underscore.
  (should (eq (my-thingatpt-tests--value "x_-|1" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "_+|1" #'my/thingatpt-integer-match) 'demoted))
  ;; Another + or -.
  (should (eq (my-thingatpt-tests--value "++|1" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "+-|1" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "-+|1" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "--|1" #'my/thingatpt-integer-match) 'demoted))
  ;; A closing bracket.
  (should (eq (my-thingatpt-tests--value "f(x)-|1" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "a[0]-|1" #'my/thingatpt-integer-match) 'demoted))
  (should (eq (my-thingatpt-tests--value "${name}-|1" #'my/thingatpt-integer-match) 'demoted))
  ;; The demoted sign is not part of the match.
  (should (equal (my-thingatpt-tests--edit "1-|2" #'my/thingatpt-integer-increment 1) "1-3|"))
  (should (equal (my-thingatpt-tests--edit "a-|1" #'my/thingatpt-integer-increment 1) "a-2|"))
  (should (equal (my-thingatpt-tests--edit "--|1" #'my/thingatpt-integer-increment 1) "--2|"))
  (should (equal (my-thingatpt-tests--edit "f(x)-|1" #'my/thingatpt-integer-increment 1) "f(x)-2|"))
  (should (equal (my-thingatpt-tests--edit "2006-01-|02" #'my/thingatpt-integer-increment 1) "2006-01-3|"))
  ;; Point is before the demoted sign.
  (should-not (my-thingatpt-tests--value "a|-1" #'my/thingatpt-integer-match))
  (should (eq (my-thingatpt-tests--value "1|-2" #'my/thingatpt-integer-match) t))
  (should (equal (my-thingatpt-tests--edit "1|-2" #'my/thingatpt-integer-increment 1) "2|-2"))
  ;; The sign of a non-decimal integer.
  (should (equal (my-thingatpt-tests--edit "1-|0x10" #'my/thingatpt-integer-increment 1) "1-0x11|"))
  ;; e in a hexadecimal integer is a letter.
  (should (eq (my-thingatpt-tests--value "0x1e-|3" #'my/thingatpt-integer-match) 'demoted))
  (should (equal (my-thingatpt-tests--edit "0x1e-|3" #'my/thingatpt-integer-increment 1) "0x1e-4|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-match-sign-kept ()
  (should (eq (my-thingatpt-tests--value " -|1" #'my/thingatpt-integer-match) t))
  (should (eq (my-thingatpt-tests--value "\t-|1" #'my/thingatpt-integer-match) t))
  (should (eq (my-thingatpt-tests--value "(+|1" #'my/thingatpt-integer-match) t))
  (should (eq (my-thingatpt-tests--value "(-|1" #'my/thingatpt-integer-match) t))
  (should (equal (my-thingatpt-tests--edit "(-|1" #'my/thingatpt-integer-increment 1) "(0|"))
  (should (equal (my-thingatpt-tests--edit "a[-|1]" #'my/thingatpt-integer-increment 1) "a[0|]"))
  (should (equal (my-thingatpt-tests--edit "{-|1, 1}" #'my/thingatpt-integer-increment 1) "{0|, 1}"))
  (should (equal (my-thingatpt-tests--edit "x=-|1" #'my/thingatpt-integer-increment 1) "x=0|"))
  (should (equal (my-thingatpt-tests--edit "x>-|1" #'my/thingatpt-integer-increment 1) "x>0|"))
  (should (equal (my-thingatpt-tests--edit "x<-|1" #'my/thingatpt-integer-increment 1) "x<0|"))
  (should (equal (my-thingatpt-tests--edit "(1,-|1)" #'my/thingatpt-integer-increment 1) "(1,0|)"))
  (should (equal (my-thingatpt-tests--edit "a[1:-|1]" #'my/thingatpt-integer-increment 1) "a[1:0|]"))
  (should (equal (my-thingatpt-tests--edit "2*-|1" #'my/thingatpt-integer-increment 1) "2*0|"))
  (should (equal (my-thingatpt-tests--edit "10^-|3" #'my/thingatpt-integer-increment 1) "10^-2|"))
  (should (equal (my-thingatpt-tests--edit "a[0..-|1]" #'my/thingatpt-integer-increment 1) "a[0..0|]"))
  (should (equal (my-thingatpt-tests--edit "\"-|1\"" #'my/thingatpt-integer-increment 1) "\"0|\""))
  (should (equal (my-thingatpt-tests--edit "'-|1'" #'my/thingatpt-integer-increment 1) "'0|'")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-match-decimal-suffix ()
  (should (equal (my-thingatpt-tests--edit "1|e" #'my/thingatpt-integer-increment 1) "2|e"))
  (should (equal (my-thingatpt-tests--edit "1|px" #'my/thingatpt-integer-increment 1) "2|px"))
  (should (equal (my-thingatpt-tests--edit "1|km" #'my/thingatpt-integer-increment 1) "2|km"))
  (should (equal (my-thingatpt-tests--edit "1|UL" #'my/thingatpt-integer-increment 1) "2|UL"))
  (should (equal (my-thingatpt-tests--edit "1|f32" #'my/thingatpt-integer-increment 1) "2|f32"))
  (should (equal (my-thingatpt-tests--edit "1|_" #'my/thingatpt-integer-increment 1) "2|_"))
  ;; e is an exponent indicator only if it is followed by digits.
  (should (equal (my-thingatpt-tests--edit "1|e+" #'my/thingatpt-integer-increment 1) "2|e+"))
  (should (equal (my-thingatpt-tests--edit "1|e-x" #'my/thingatpt-integer-increment 1) "2|e-x"))
  (should (equal (my-thingatpt-tests--edit "1|em" #'my/thingatpt-integer-increment 1) "2|em"))
  ;; b, o, and x are suffixes unless the digits are exactly 0.
  (should (equal (my-thingatpt-tests--edit "10|b" #'my/thingatpt-integer-increment 1) "11|b"))
  (should (equal (my-thingatpt-tests--edit "10|o" #'my/thingatpt-integer-increment 1) "11|o"))
  (should (equal (my-thingatpt-tests--edit "10|x" #'my/thingatpt-integer-increment 1) "11|x"))
  ;; The suffix is not part of the match.
  (should-not (my-thingatpt-tests--value "1p|x" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "1px|" #'my/thingatpt-integer-match))
  ;; The digits in the suffix is an integer of its own.
  (should (equal (my-thingatpt-tests--edit "1f3|2" #'my/thingatpt-integer-increment 1) "1f33|"))
  ;; A letter before the integer.
  (should (equal (my-thingatpt-tests--edit "a|1" #'my/thingatpt-integer-increment 1) "a2|"))
  (should (equal (my-thingatpt-tests--edit "_|1" #'my/thingatpt-integer-increment 1) "_2|"))
  (should (equal (my-thingatpt-tests--edit "#|1" #'my/thingatpt-integer-increment 1) "#2|"))
  ;; Each side of a decimal point is an integer of its own.
  (should (equal (my-thingatpt-tests--edit "1|.5" #'my/thingatpt-integer-increment 1) "2|.5"))
  (should (equal (my-thingatpt-tests--edit "1.|5" #'my/thingatpt-integer-increment 1) "1.6|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-match-bare-base-prefix ()
  (should-not (my-thingatpt-tests--value "|0x" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0|x" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0x|" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0|b" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0|o" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0|X" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "(0|x)" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "-0|x" #'my/thingatpt-integer-match))
  ;; The base prefix is followed by something that is not a valid digit.
  (should-not (my-thingatpt-tests--value "0|xg" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0|b2" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0|o8" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0|x_ff" #'my/thingatpt-integer-match))
  ;; The letters, digits, and underscores that follow are consumed.
  (should-not (my-thingatpt-tests--value "0b|2" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0b2|" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0xg|1" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0xg_1|" #'my/thingatpt-integer-match))
  ;; The search continues after it.
  (should (equal (my-thingatpt-tests--edit "0x 4|2" #'my/thingatpt-integer-increment 1) "0x 43|"))
  (should (equal (my-thingatpt-tests--edit "0b2 4|2" #'my/thingatpt-integer-increment 1) "0b2 43|"))
  ;; The base prefix is followed by a valid digit.
  (should (equal (my-thingatpt-tests--edit "0|x123" #'my/thingatpt-integer-increment 1) "0x124|"))
  (should (equal (my-thingatpt-tests--edit "0|x123deadbeef" #'my/thingatpt-integer-increment 1) "0x123deadbef0|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-match-non-decimal-suffix ()
  ;; A letter that is not a digit is a suffix.
  (should (equal (my-thingatpt-tests--edit "0x1|23m" #'my/thingatpt-integer-increment 1) "0x124|m"))
  (should (equal (my-thingatpt-tests--edit "0xdead|beefg" #'my/thingatpt-integer-increment 1) "0xdeadbef0|g"))
  (should (equal (my-thingatpt-tests--edit "0b1|u8" #'my/thingatpt-integer-increment 1) "0b10|u8"))
  (should (equal (my-thingatpt-tests--edit "0o7|i32" #'my/thingatpt-integer-increment 1) "0o10|i32"))
  (should (equal (my-thingatpt-tests--edit "(0xf|f)" #'my/thingatpt-integer-increment 1) "(0x100|)"))
  ;; A digit that is not a digit of the base makes the integer invalid.
  (should-not (my-thingatpt-tests--value "0b1|2" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "|0b12" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0b1|02" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0o1|9" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0o17|8" #'my/thingatpt-integer-match))
  ;; The letters, digits, and underscores that follow are consumed.
  (should-not (my-thingatpt-tests--value "0b12|" #'my/thingatpt-integer-match))
  (should-not (my-thingatpt-tests--value "0b12a_|3" #'my/thingatpt-integer-match))
  ;; The search continues after it.
  (should (equal (my-thingatpt-tests--edit "0b12 4|2" #'my/thingatpt-integer-increment 1) "0b12 43|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-match-longest-digits ()
  ;; e is a digit, not an exponent indicator.
  (should (equal (my-thingatpt-tests--edit "|0x1e3" #'my/thingatpt-integer-increment 1) "0x1e4|"))
  ;; e is a digit, so the suffix is m, not em.
  (should (equal (my-thingatpt-tests--edit "|0x10em" #'my/thingatpt-integer-increment 1) "0x10f|m"))
  ;; f32 is not a suffix.
  (should (equal (my-thingatpt-tests--edit "|0x1f32" #'my/thingatpt-integer-increment 1) "0x1f33|"))
  ;; b is a digit, not a base prefix.
  (should (equal (my-thingatpt-tests--edit "|0x0b1" #'my/thingatpt-integer-increment 1) "0xb2|"))
  ;; Only decimal integers have exponent part.
  (should (equal (my-thingatpt-tests--edit "|0b1e5" #'my/thingatpt-integer-increment 1) "0b10|e5"))
  ;; 0x1080 is not tried because 1920 is taken first.
  (should (equal (my-thingatpt-tests--edit "1920|x1080" #'my/thingatpt-integer-increment 1) "1921|x1080"))
  (should (equal (my-thingatpt-tests--edit "1920x|1080" #'my/thingatpt-integer-increment 1) "1920x1081|"))
  (should (equal (my-thingatpt-tests--edit "1|0x10" #'my/thingatpt-integer-increment 1) "11|x10")))

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
  (should (equal (my-thingatpt-tests--edit "|0b111" #'my/thingatpt-integer-increment 1) "0b1000|"))
  (should (equal (my-thingatpt-tests--edit "|0b101" #'my/thingatpt-integer-increment -1) "0b100|"))
  (should (equal (my-thingatpt-tests--edit "|0b0" #'my/thingatpt-integer-increment -1) "-0b1|"))
  (should (equal (my-thingatpt-tests--edit "|-0b1" #'my/thingatpt-integer-increment 3) "0b10|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-octal ()
  (should (equal (my-thingatpt-tests--edit "|0o17" #'my/thingatpt-integer-increment 1) "0o20|"))
  (should (equal (my-thingatpt-tests--edit "|0O17" #'my/thingatpt-integer-increment 1) "0O20|"))
  (should (equal (my-thingatpt-tests--edit "|0o777" #'my/thingatpt-integer-increment 1) "0o1000|"))
  (should (equal (my-thingatpt-tests--edit "|0o20" #'my/thingatpt-integer-increment -1) "0o17|"))
  (should (equal (my-thingatpt-tests--edit "|0o0" #'my/thingatpt-integer-increment -1) "-0o1|")))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-hexadecimal ()
  (should (equal (my-thingatpt-tests--edit "|0xfe" #'my/thingatpt-integer-increment 1) "0xff|"))
  (should (equal (my-thingatpt-tests--edit "|0Xfe" #'my/thingatpt-integer-increment 1) "0Xff|"))
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

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-increment-demoted-sign ()
  ;; The result is not negative.
  (should (equal (my-thingatpt-tests--edit "1-|2" #'my/thingatpt-integer-increment -2) "1-0|"))
  (should (equal (my-thingatpt-tests--edit "1+|2" #'my/thingatpt-integer-increment -2) "1+0|"))
  (should (equal (my-thingatpt-tests--edit "1-|2" #'my/thingatpt-integer-increment 10) "1-12|"))
  ;; The result is negative.
  (should-error (my-thingatpt-tests--edit "1-|2" #'my/thingatpt-integer-increment -3) :type 'user-error)
  (should-error (my-thingatpt-tests--edit "1+|2" #'my/thingatpt-integer-increment -3) :type 'user-error)
  (should-error (my-thingatpt-tests--edit "1-|0" #'my/thingatpt-integer-decrement 1) :type 'user-error)
  (should-error (my-thingatpt-tests--edit "a-|0x1" #'my/thingatpt-integer-decrement 2) :type 'user-error)
  ;; The buffer is not changed on error.
  (with-temp-buffer
    (insert "1-2")
    (goto-char 3)
    (should-error (my/thingatpt-integer-increment -3) :type 'user-error)
    (should (equal (buffer-string) "1-2"))
    (should (equal (point) 3)))
  ;; The exponent part can be negative.
  (should (equal (my-thingatpt-tests--edit "1-2e|1" #'my/thingatpt-integer-increment -3) "1-2e-2|"))
  ;; Nothing is demoted if there is no + or -, so the result can be negative.
  (should (equal (my-thingatpt-tests--edit "a|1" #'my/thingatpt-integer-increment -2) "a-1|")))

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

;;;; Integer regexps

(ert-deftest my-thingatpt-tests-my/thingatpt-binary-integer-regexp ()
  (let ((regexp my/thingatpt-binary-integer-regexp))
    (should (equal (my-thingatpt-tests--match-string regexp "0b101" 0) "0b101"))
    (should (equal (my-thingatpt-tests--match-string regexp "-0B1_0" 0) "-0B1_0"))
    (should (equal (my-thingatpt-tests--match-string regexp "-0b101" 2) "-"))
    (should (equal (my-thingatpt-tests--match-string regexp "-0b101" 3) "0b"))
    (should (equal (my-thingatpt-tests--match-string regexp "-0b101" 4) "101"))
    ;; The suffix is not part of the match.
    (should (equal (my-thingatpt-tests--match-string regexp "0b101u8" 0) "0b101"))
    (should (equal (my-thingatpt-tests--match-string regexp "0b101u8" 8) ""))
    ;; An underscore must be between digits.
    (should (equal (my-thingatpt-tests--match-string regexp "0b1_" 0) "0b1"))
    (should (equal (my-thingatpt-tests--match-string regexp "0b1__0" 0) "0b1"))
    ;; Invalid.
    (should (equal (my-thingatpt-tests--match-string regexp "0b12" 8) "2"))
    (should (equal (my-thingatpt-tests--match-string regexp "0b1029a_ b" 8) "29a_"))
    ;; No match.
    (should-not (my-thingatpt-tests--match-string regexp "0b" 0))
    (should-not (my-thingatpt-tests--match-string regexp "0b2" 0))
    (should-not (my-thingatpt-tests--match-string regexp "0b_1" 0))
    (should-not (my-thingatpt-tests--match-string regexp "101" 0))))

(ert-deftest my-thingatpt-tests-my/thingatpt-octal-integer-regexp ()
  (let ((regexp my/thingatpt-octal-integer-regexp))
    (should (equal (my-thingatpt-tests--match-string regexp "0o17" 0) "0o17"))
    (should (equal (my-thingatpt-tests--match-string regexp "+0O7_7" 0) "+0O7_7"))
    (should (equal (my-thingatpt-tests--match-string regexp "+0o17" 2) "+"))
    (should (equal (my-thingatpt-tests--match-string regexp "+0o17" 3) "0o"))
    (should (equal (my-thingatpt-tests--match-string regexp "+0o17" 4) "17"))
    ;; The suffix is not part of the match.
    (should (equal (my-thingatpt-tests--match-string regexp "0o17i32" 0) "0o17"))
    (should (equal (my-thingatpt-tests--match-string regexp "0o17i32" 8) ""))
    ;; Invalid.
    (should (equal (my-thingatpt-tests--match-string regexp "0o19" 8) "9"))
    (should (equal (my-thingatpt-tests--match-string regexp "0o178z)" 8) "8z"))
    ;; No match.
    (should-not (my-thingatpt-tests--match-string regexp "0o" 0))
    (should-not (my-thingatpt-tests--match-string regexp "0o8" 0))
    (should-not (my-thingatpt-tests--match-string regexp "17" 0))))

(ert-deftest my-thingatpt-tests-my/thingatpt-hexadecimal-integer-regexp ()
  (let ((regexp my/thingatpt-hexadecimal-integer-regexp))
    (should (equal (my-thingatpt-tests--match-string regexp "0xff" 0) "0xff"))
    (should (equal (my-thingatpt-tests--match-string regexp "-0XFF_ff" 0) "-0XFF_ff"))
    (should (equal (my-thingatpt-tests--match-string regexp "-0xff" 2) "-"))
    (should (equal (my-thingatpt-tests--match-string regexp "-0xff" 3) "0x"))
    (should (equal (my-thingatpt-tests--match-string regexp "-0xff" 4) "ff"))
    ;; The suffix is not part of the match.
    (should (equal (my-thingatpt-tests--match-string regexp "0xffg" 0) "0xff"))
    ;; It is never invalid.
    (should-not (my-thingatpt-tests--match-string regexp "0xffg" 8))
    ;; No match.
    (should-not (my-thingatpt-tests--match-string regexp "0x" 0))
    (should-not (my-thingatpt-tests--match-string regexp "0xg" 0))
    (should-not (my-thingatpt-tests--match-string regexp "ff" 0))))

(ert-deftest my-thingatpt-tests-my/thingatpt-bare-base-prefix-regexp ()
  (let ((regexp my/thingatpt-bare-base-prefix-regexp))
    (should (equal (my-thingatpt-tests--match-string regexp "0x" 8) "0x"))
    (should (equal (my-thingatpt-tests--match-string regexp "0B" 8) "0B"))
    (should (equal (my-thingatpt-tests--match-string regexp "0o)" 8) "0o"))
    ;; The letters, digits, and underscores that follow are consumed.
    (should (equal (my-thingatpt-tests--match-string regexp "0b2" 8) "0b2"))
    (should (equal (my-thingatpt-tests--match-string regexp "0xg_1 2" 8) "0xg_1"))
    ;; The sign is consumed.
    (should (equal (my-thingatpt-tests--match-string regexp "-0x" 0) "-0x"))
    ;; No match.
    (should-not (my-thingatpt-tests--match-string regexp "0" 0))
    (should-not (my-thingatpt-tests--match-string regexp "10x" 0))))

(ert-deftest my-thingatpt-tests-my/thingatpt-decimal-integer-regexp ()
  (let ((regexp my/thingatpt-decimal-integer-regexp))
    (should (equal (my-thingatpt-tests--match-string regexp "42" 0) "42"))
    (should (equal (my-thingatpt-tests--match-string regexp "-1_000" 0) "-1_000"))
    (should (equal (my-thingatpt-tests--match-string regexp "-1_000" 2) "-"))
    (should (equal (my-thingatpt-tests--match-string regexp "-1_000" 4) "1_000"))
    (should-not (my-thingatpt-tests--match-string regexp "-1_000" 3))
    ;; Exponent.
    (should (equal (my-thingatpt-tests--match-string regexp "1e10" 0) "1e10"))
    (should (equal (my-thingatpt-tests--match-string regexp "1E-1_0" 0) "1E-1_0"))
    (should (equal (my-thingatpt-tests--match-string regexp "-2e-10" 1) "-2"))
    (should (equal (my-thingatpt-tests--match-string regexp "-2e-10" 5) "-10"))
    (should (equal (my-thingatpt-tests--match-string regexp "-2e-10" 6) "-"))
    (should (equal (my-thingatpt-tests--match-string regexp "-2e-10" 7) "10"))
    ;; e is an exponent indicator only if it is followed by digits.
    (should (equal (my-thingatpt-tests--match-string regexp "1e" 0) "1"))
    (should (equal (my-thingatpt-tests--match-string regexp "1e+" 0) "1"))
    (should-not (my-thingatpt-tests--match-string regexp "1e" 5))
    ;; The suffix is not part of the match.
    (should (equal (my-thingatpt-tests--match-string regexp "1px" 0) "1"))
    ;; No match.
    (should-not (my-thingatpt-tests--match-string regexp "px" 0))
    (should-not (my-thingatpt-tests--match-string regexp "-" 0))))

(ert-deftest my-thingatpt-tests-my/thingatpt-integer-regexp ()
  (let ((regexp my/thingatpt-integer-regexp))
    (should (equal (my-thingatpt-tests--match-string regexp "0b101" 0) "0b101"))
    (should (equal (my-thingatpt-tests--match-string regexp "0o17" 0) "0o17"))
    (should (equal (my-thingatpt-tests--match-string regexp "0xff" 0) "0xff"))
    (should (equal (my-thingatpt-tests--match-string regexp "1e10" 0) "1e10"))
    ;; A bare base prefix is not the decimal integer 0.
    (should (equal (my-thingatpt-tests--match-string regexp "0x" 8) "0x"))
    (should (equal (my-thingatpt-tests--match-string regexp "0b2" 8) "0b2"))
    ;; The groups of the other alternatives do not match.
    (should-not (my-thingatpt-tests--match-string regexp "42" 3))
    (should-not (my-thingatpt-tests--match-string regexp "42" 8))
    (should-not (my-thingatpt-tests--match-string regexp "0x" 4))))

(ert-deftest my-thingatpt-tests-my/thingatpt-sign-demoting-regexp ()
  (dolist (string '("0" "9" "a" "z" "A" "Z" "_" ")" "]" "}" "+" "-"))
    (should (string-match-p my/thingatpt-sign-demoting-regexp string)))
  (dolist (string '(" " "!" "\"" "#" "$" "%" "&" "'" "(" "*" "," "." "/" ":" ";" "<" "="
                    ">" "?" "@" "[" "\\" "^" "`" "{" "|" "~"))
    (should-not (string-match-p my/thingatpt-sign-demoting-regexp string))))

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
  (should (equal (my/thingatpt--increment "" "0X" "9" 1) "0Xa"))
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
