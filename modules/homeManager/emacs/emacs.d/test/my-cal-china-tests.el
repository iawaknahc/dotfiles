;;; my-cal-china-tests.el --- my-cal-china-tests.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ert)
(require 'my-cal-china)

(ert-deftest my-cal-china-tests-my/calendar-chinese-date-string-from-gregorian ()
  (should
   (equal
    (my/calendar-chinese-date-string-from-gregorian '(2 7 2008))
    "(循環78 25年 始於1984年 肖鼠) 戊子年正月初一"))
  (should
   (equal
    (my/calendar-chinese-date-string-from-gregorian '(1 26 2009))
    "(循環78 26年 始於1984年 肖牛) 己丑年正月初一"))
  (should
   (equal
    (my/calendar-chinese-date-string-from-gregorian '(2 14 2010))
    "(循環78 27年 始於1984年 肖虎) 庚寅年正月初一"))
  (should
   (equal
    (my/calendar-chinese-date-string-from-gregorian '(2 3 2011))
    "(循環78 28年 始於1984年 肖兔) 辛卯年正月初一")))

(ert-deftest my-cal-china-tests-my/calendar-chinese-year-with-month-length ()
  ;; A year without leap month.
  (should
   (equal
    (my/calendar-chinese-year-with-month-length 2024)
    '((12 738896 30)
      (1 738926 29)
      (2 738955 30)
      (3 738985 29)
      (4 739014 29)
      (5 739043 30)
      (6 739073 29)
      (7 739102 30)
      (8 739132 30)
      (9 739162 29)
      (10 739191 30)
      (11 739221 30))))
  ;; A year with 閏二月.
  (should
   (equal
    (my/calendar-chinese-year-with-month-length 2023)
    '((12 738512 30)
      (1 738542 29)
      (2 738571 30)
      (2.5 738601 29)
      (3 738630 29)
      (4 738659 30)
      (5 738689 30)
      (6 738719 29)
      (7 738748 30)
      (8 738778 30)
      (9 738808 29)
      (10 738837 30)
      (11 738867 29))))
  ;; 閏冬月 of 2033 is the first element of 2034.
  (should
   (equal
    (my/calendar-chinese-year-with-month-length 2034)
    '((11.5 742529 29)
      (12 742558 30)
      (1 742588 29)
      (2 742617 30)
      (3 742647 29)
      (4 742676 29)
      (5 742705 30)
      (6 742735 29)
      (7 742764 30)
      (8 742794 29)
      (9 742823 30)
      (10 742853 30)
      (11 742883 29)))))

(ert-deftest my-cal-china-tests-my/calendar-chinese-year-with-month-length-invariants ()
  (dolist (year (number-sequence 1900 2100))
    (let* ((result (my/calendar-chinese-year-with-month-length year))
           (next-result (my/calendar-chinese-year-with-month-length (1+ year))))
      ;; The first two elements are the same as `calendar-chinese-year'.
      (should
       (equal
        (mapcar (lambda (x) (list (nth 0 x) (nth 1 x))) result)
        (calendar-chinese-year year)))
      ;; The month length is either 29 or 30.
      (dolist (x result)
        (should (memq (nth 2 x) '(29 30)))))))

(ert-deftest my-cal-china-tests-my/calendar-chinese-anniversary ()
  ;; 甲辰年正月初一
  (should
   (equal
    (my/calendar-chinese-anniversary '(2 10 2024) 2024)
    '(:order 0
             :date-gregorian (2 10 2024)
             :date-chinese (78 41 1 1)
             :anniversary-gregorian (2 10 2024)
             :anniversary-chinese (78 41 1 1))))
  (should
   (equal
    (my/calendar-chinese-anniversary '(2 10 2024) 2025)
    '(:order 1
             :date-gregorian (2 10 2024)
             :date-chinese (78 41 1 1)
             :anniversary-gregorian (1 29 2025)
             :anniversary-chinese (78 42 1 1))))
  (should
   (equal
    (my/calendar-chinese-anniversary '(2 10 2024) 2023)
    '(:order -1
             :date-gregorian (2 10 2024)
             :date-chinese (78 41 1 1)
             :anniversary-gregorian (1 22 2023)
             :anniversary-chinese (78 40 1 1))))
  ;; 癸卯年臘月初一
  (should
   (equal
    (my/calendar-chinese-anniversary '(1 11 2024) 2024)
    '(:order 0
             :date-gregorian (1 11 2024)
             :date-chinese (78 40 12 1)
             :anniversary-gregorian (1 11 2024)
             :anniversary-chinese (78 40 12 1))))
  (should
   (equal
    (my/calendar-chinese-anniversary '(1 11 2024) 2026)
    '(:order 2
             :date-gregorian (1 11 2024)
             :date-chinese (78 40 12 1)
             :anniversary-gregorian (1 19 2026)
             :anniversary-chinese (78 42 12 1)))))

(ert-deftest my-cal-china-tests-my/calendar-chinese-anniversary-across-cycles ()
  ;; 循環78 1年
  (should
   (equal
    (my/calendar-chinese-anniversary '(2 10 2024) 1984)
    '(:order -40
             :date-gregorian (2 10 2024)
             :date-chinese (78 41 1 1)
             :anniversary-gregorian (2 2 1984)
             :anniversary-chinese (78 1 1 1))))
  ;; 循環77 60年
  (should
   (equal
    (my/calendar-chinese-anniversary '(2 10 2024) 1983)
    '(:order -41
             :date-gregorian (2 10 2024)
             :date-chinese (78 41 1 1)
             :anniversary-gregorian (2 13 1983)
             :anniversary-chinese (77 60 1 1)))))

(ert-deftest my-cal-china-tests-my/calendar-chinese-anniversary-leap-month ()
  ;; 癸卯年閏二月初一 is returned as is when the order is 0.
  (should
   (equal
    (my/calendar-chinese-anniversary '(3 22 2023) 2023)
    '(:order 0
             :date-gregorian (3 22 2023)
             :date-chinese (78 40 2.5 1)
             :anniversary-gregorian (3 22 2023)
             :anniversary-chinese (78 40 2.5 1))))
  ;; Otherwise, it is taken as 二月初一.
  (should
   (equal
    (my/calendar-chinese-anniversary '(3 22 2023) 2024)
    '(:order 1
             :date-gregorian (3 22 2023)
             :date-chinese (78 40 2.5 1)
             :anniversary-gregorian (3 10 2024)
             :anniversary-chinese (78 41 2 1))))
  ;; 癸卯年閏二月十五
  (should
   (equal
    (my/calendar-chinese-anniversary '(4 5 2023) 2025)
    '(:order 2
             :date-gregorian (4 5 2023)
             :date-chinese (78 40 2.5 15)
             :anniversary-gregorian (3 14 2025)
             :anniversary-chinese (78 42 2 15))))
  ;; 癸丑年閏冬月初一
  (should
   (equal
    (my/calendar-chinese-anniversary '(12 22 2033) 2033)
    '(:order 0
             :date-gregorian (12 22 2033)
             :date-chinese (78 50 11.5 1)
             :anniversary-gregorian (12 22 2033)
             :anniversary-chinese (78 50 11.5 1))))
  (should
   (equal
    (my/calendar-chinese-anniversary '(12 22 2033) 2034)
    '(:order 1
             :date-gregorian (12 22 2033)
             :date-chinese (78 50 11.5 1)
             :anniversary-gregorian (12 11 2034)
             :anniversary-chinese (78 51 11 1)))))

(ert-deftest my-cal-china-tests-my/calendar-chinese-anniversary-day-30 ()
  ;; 甲辰年二月三十
  (should
   (equal
    (my/calendar-chinese-anniversary '(4 8 2024) 2024)
    '(:order 0
             :date-gregorian (4 8 2024)
             :date-chinese (78 41 2 30)
             :anniversary-gregorian (4 8 2024)
             :anniversary-chinese (78 41 2 30))))
  ;; 癸卯年二月 has 三十.
  (should
   (equal
    (my/calendar-chinese-anniversary '(4 8 2024) 2023)
    '(:order -1
             :date-gregorian (4 8 2024)
             :date-chinese (78 41 2 30)
             :anniversary-gregorian (3 21 2023)
             :anniversary-chinese (78 40 2 30))))
  ;; 乙巳年二月 does not have 三十, so 廿九 is used.
  (should
   (equal
    (my/calendar-chinese-anniversary '(4 8 2024) 2025)
    '(:order 1
             :date-gregorian (4 8 2024)
             :date-chinese (78 41 2 30)
             :anniversary-gregorian (3 28 2025)
             :anniversary-chinese (78 42 2 29)))))

(ert-deftest my-cal-china-tests-my/calendar-chinese-anniversary-not-in-year ()
  ;; 癸卯年臘月初一
  ;; 臘月 can start in the previous Gregorian year.
  (should
   (equal
    (my/calendar-chinese-anniversary '(1 11 2024) 2025)
    '(:order 1
             :date-gregorian (1 11 2024)
             :date-chinese (78 40 12 1)
             :anniversary-gregorian (12 31 2024)
             :anniversary-chinese (78 41 12 1))))
  (should
   (equal
    (my/calendar-chinese-anniversary '(1 11 2024) 2023)
    '(:order -1
             :date-gregorian (1 11 2024)
             :date-chinese (78 40 12 1)
             :anniversary-gregorian (12 23 2022)
             :anniversary-chinese (78 39 12 1))))
  (should
   (equal
    (my/calendar-chinese-anniversary '(1 11 2024) 2024)
    '(:order 0
             :date-gregorian (1 11 2024)
             :date-chinese (78 40 12 1)
             :anniversary-gregorian (1 11 2024)
             :anniversary-chinese (78 40 12 1))))
  ;; 癸卯年冬月廿一
  ;; 冬月 can end in the next Gregorian year.
  (should
   (equal
    (my/calendar-chinese-anniversary '(1 2 2024) 2023)
    '(:order 0
             :date-gregorian (1 2 2024)
             :date-chinese (78 40 11 21)
             :anniversary-gregorian (1 2 2024)
             :anniversary-chinese (78 40 11 21))))
  (should
   (equal
    (my/calendar-chinese-anniversary '(1 2 2024) 2025)
    '(:order 2
             :date-gregorian (1 2 2024)
             :date-chinese (78 40 11 21)
             :anniversary-gregorian (1 9 2026)
             :anniversary-chinese (78 42 11 21))))
  (should
   (equal
    (my/calendar-chinese-anniversary '(1 2 2024) 2024)
    '(:order 1
             :date-gregorian (1 2 2024)
             :date-chinese (78 40 11 21)
             :anniversary-gregorian (12 21 2024)
             :anniversary-chinese (78 41 11 21)))))

(provide 'my-cal-china-tests)
;;; my-cal-china-tests.el ends here
