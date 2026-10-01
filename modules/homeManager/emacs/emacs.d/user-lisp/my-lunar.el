;;; my-lunar.el --- my-lunar.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; `lunar-new-moon-on-or-after'
(require 'lunar)
;; `calendar-astro-from-absolute'
(require 'cal-julian)
;; `calendar-absolute-from-gregorian'
(require 'calendar)

(defconst my/lunar-phase-names
  '(("New Moon" "朔月" "🌑")         ;; 0
    ("Waxing Crescent" "眉月" "🌒")  ;; 0.125
    ("First Quarter" "上弦" "🌓")    ;; 0.25
    ("Waxing Gibbous" "盈凸" "🌔")   ;; 0.375
    ("Full Moon" "望月" "🌕")        ;; 0.5
    ("Waning Gibbous" "虧凸" "🌖")   ;; 0.625
    ("Last Quarter" "下弦" "🌗")     ;; 0.75
    ("Waning Crescent" "殘月" "🌘")  ;; 0.875
    ("New Moon" "晦月" "🌑"))        ;; 1
  "A list of lunar phase names.
The first element is the English name.
The second element is the Chinese name.
The third element is the emoji.")

;;;###autoload
(defun my/lunar-phase-of-astro (astro-date)
  "Return the lunar phase of calendar-astro date ASTRO-DATE.

The return value is a list.
The first element is the length of the lunar cycle, in Julian day number.
The second element is the elapsed time in this cycle, in Julian day number.
The third element is the lunar phase, ranged from 0 to 8, where 0 means 朔月, 4 means 望月, and 8 means 晦月"
  (let* ((next-new-moon (lunar-new-moon-on-or-after astro-date))
         prev-new-moon
         lunar-cycle-length
         elapsed
         elapsed-percent
         phase)
    (cond
     ((eql next-new-moon astro-date)
      (setq prev-new-moon next-new-moon)
      (setq next-new-moon (lunar-new-moon-on-or-after (+ astro-date 1))))
     (t
      (setq prev-new-moon (lunar-new-moon-on-or-after (- next-new-moon 30)))))
    (setq lunar-cycle-length (- next-new-moon prev-new-moon))
    (setq elapsed (- astro-date prev-new-moon))
    (setq elapsed-percent (/ elapsed lunar-cycle-length))
    (setq phase (round (* 8 elapsed-percent)))
    (cl-assert (and (> lunar-cycle-length 29) (< lunar-cycle-length 30)))
    (cl-assert (and (>= phase 0) (<= phase 8)))
    (list lunar-cycle-length elapsed phase)))

;;;###autoload
(defun my/lunar-phase-of-date (date)
  "Return the lunar phase of Gregorian date DATE.

The return value is a list.
The first element is the length of the lunar cycle, in Julian day number.
The second element is the elapsed time in this cycle, in Julian day number.
The third element is the lunar phase, ranged from 0 to 8, where 0 means 朔月, 4 means 望月, and 8 means 晦月"
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (astro-date (calendar-astro-from-absolute abs-date)))
    (my/lunar-phase-of-astro astro-date)))

;;;###autoload
(defun my/lunar-phase-date-string (date)
  "Return a string intended to be used in `calendar-mode-line-format' for DATE."
  (pcase-let* ((`(,lunar-cycle-length ,elapsed ,phase) (my/lunar-phase-of-date date))
               (`(,english ,chinese ,emoji) (nth phase my/lunar-phase-names))
               (percent (* 100 (/ elapsed lunar-cycle-length))))
    (format "(%5.2f/%5.2f %3.0f%%%% %s %s)" elapsed lunar-cycle-length percent chinese emoji)))

(provide 'my-lunar)
;;; my-lunar.el ends here
