;;; my-lunar-tests.el --- my-lunar-tests.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ert)
(require 'my-lunar)

(ert-deftest my-lunar-tests-my/lunar-phase-date-string ()
  (should
   (equal
    (my/lunar-phase-date-string '(9 11 2026))
    "(28.93/29.41  98%% 晦月 🌑)"))
  (should
   (equal
    (my/lunar-phase-date-string '(9 12 2026))
    "( 0.52/29.52   2%% 朔月 🌑)"))
  (should
   (equal
    (my/lunar-phase-date-string '(9 19 2026))
    "( 7.52/29.52  25%% 上弦 🌓)"))
  (should
   (equal
    (my/lunar-phase-date-string '(9 27 2026))
    "(15.52/29.52  53%% 望月 🌕)"))
  (should
   (equal
    (my/lunar-phase-date-string '(10 3 2026))
    "(21.52/29.52  73%% 下弦 🌗)"))
  (should
   (equal
    (my/lunar-phase-date-string '(10 10 2026))
    "(28.52/29.52  97%% 晦月 🌑)"))
  (should
   (equal
    (my/lunar-phase-date-string '(10 11 2026))
    "( 0.01/29.63   0%% 朔月 🌑)")))

(provide 'my-lunar-tests)
;;; my-lunar-tests.el ends here
