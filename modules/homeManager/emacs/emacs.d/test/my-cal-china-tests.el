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

(provide 'my-cal-china-tests)
;;; my-cal-china-tests.el ends here
