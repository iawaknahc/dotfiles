;;; my-datetime-tests.el --- my-datetime-tests.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ert)
(require 'my-datetime)

(ert-deftest my-datetime-tests-my/current-time ()
  (should
   (pcase (my/current-time)
     (`(,ticks . ,hz)
      (should (numberp ticks))
      (should (numberp hz)))
     (_ nil))))

(ert-deftest my-datetime-tests-my/decode-time ()
  (should
   (equal
    (my/decode-time '(1791370647576471000 . 1000000000) "Asia/Hong_Kong")
    '((27576471000 . 1000000000) 57 18 7 10 2026 3 nil 28800))))

(ert-deftest my-datetime-tests-my/decoded-time-second ()
  (should
   (equal
    (my/decoded-time-second '(5 4 15 2 1 2006 1 -1 25200))
    5))
  (should
   (equal
    (my/decoded-time-second '(5 4 15 2 1 2006 1 -1 25200) 'integer)
    5))
  (should
   (equal
    (my/decoded-time-second '(5 4 15 2 1 2006 1 -1 25200) 'float)
    5.0))
  (should
   (equal
    (my/decoded-time-second '((5000 . 1000) 4 15 2 1 2006 1 -1 25200))
    5.0))
  (should
   (equal
    (my/decoded-time-second '((5000 . 1000) 4 15 2 1 2006 1 -1 25200) 'integer)
    5))
  (should
   (equal
    (my/decoded-time-second '((5000 . 1000) 4 15 2 1 2006 1 -1 25200) 'float)
    5.0)))

(ert-deftest my-datetime-tests-my/decoded-time-weekday ()
  (should
   (equal
    (my/decoded-time-weekday '(5 4 15 2 1 2006 1 -1 25200))
    1))
  (should
   (equal
    (my/decoded-time-weekday '(5 4 15 1 1 2006 0 -1 25200))
    7)))

(provide 'my-datetime-tests)
;;; my-datetime-tests.el ends here
