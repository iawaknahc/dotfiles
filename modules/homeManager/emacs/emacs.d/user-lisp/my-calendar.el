;;; my-calendar.el --- my-calendar.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'calendar)
(require 'cal-julian)
(require 'solar)
(require 'holidays)

(defconst my/solar-terms
  '(("春分" 0 (3 21))
    ("清明" 15 (4 5))
    ("穀雨" 30 (4 20))
    ("立夏" 45 (5 6))
    ("小滿" 60 (5 21))
    ("芒種" 75 (6 6))
    ("夏至" 90 (6 21))
    ("小暑" 105 (7 7))
    ("大暑" 120 (7 23))
    ("立秋" 135 (8 8))
    ("處暑" 150 (8 23))
    ("白露" 165 (9 8))
    ("秋分" 180 (9 23))
    ("寒露" 195 (10 8))
    ("霜降" 210 (10 23))
    ("立冬" 225 (11 7))
    ("小雪" 240 (11 22))
    ("大雪" 255 (12 7))
    ("冬至" 270 (12 22))
    ("小寒" 285 (1 6))
    ("大寒" 300 (1 20))
    ("立春" 315 (2 4))
    ("雨水" 330 (2 19))
    ("驚蟄" 345 (3 6)))
  "A list of solar terms.
Each entry is a list of 3 elements.

The first element is the name of the solar term.

The second element is the degree of the solar term.
This is currently unused.

The third element is the typical month-day of the solar term.
This is used in `solar-date-next-longitude' because the function computes the next date.")

;;;###autoload
(defun my/solar-term (solar-term year)
  "Compute SOLAR-TERM in Gregorian YEAR.
No daylight saving is considered and the timezone is fixed to be Asia/Hong_Kong (UTC+08:00)

Return ((month day year) STRING).
The return value can be used directly as a holiday."
  ;; Return nil if solar-term is invalid
  (when-let* ((val (alist-get solar-term my/solar-terms nil nil #'string=)))
    ;; Destructure val.
    (let* ((month-day (cadr val))
           (month (car month-day))
           (day (cadr month-day))
           ;; Subtract 2 days from the typical day so that we will never overshoot.
           (start (list month (- day 2) year))
           ;; Dynamically bind the variables used by `solar-date-next-longitude'.
           (calendar-daylight-savings-starts nil)
           (calendar-daylight-savings-starts-time 0)
           (calendar-daylight-savings-ends nil)
           (calendar-chinese-daylight-saving-end-time 0)
           (calendar-daylight-time-offset 0)
           (calendar-time-zone 480)
           ;; Convert `start' to absolute date.
           (start-abs (calendar-absolute-from-gregorian start))
           ;; Convert absolute date to Julian date.
           (start-astro (calendar-astro-from-absolute start-abs))
           ;; Call `solar-date-next-longitude' to do the heavy lifting.
           (result-astro (solar-date-next-longitude start-astro 15))
           ;; Convert the result (in Julian date) to absolute date.
           (result-abs (calendar-astro-to-absolute result-astro))
           ;; Here is the tricky part.
           ;; `calendar-gregorian-from-absolute' takes integer only.
           ;; So we get the integral part of the absolute date and
           ;; feed it to `calendar-gregorian-from-absolute'.
           ;;
           ;; The fractional part depend on the dynamically bound variables we bind above.
           ;; So the fractional part is in the UTC time standard.
           ;;
           ;; We multiply the fractional part by 24 and pass it to `solar-time-string'
           ;; to get a formatted time string.
           ;; We borrow this idea from the source code of `solar-equinoxes-solstices-1'.
           (result-abs-integral (floor result-abs))
           (result-gregorian-fractional (- result-abs result-abs-integral))
           (result-gregorian-num-hours (* 24 result-gregorian-fractional))
           (result-gregorian-date (calendar-gregorian-from-absolute result-abs-integral))
           (time-string (solar-time-string result-gregorian-num-hours "HKT"))
           (holiday-description (format "%s %s" solar-term time-string)))
      (list result-gregorian-date holiday-description))))

;;;###autoload
(defun my/holiday-solar-term (solar-term)
  "An s-expression intended to be added to `holiday-other-holidays'.
Compute the holiday for SOLAR-TERM."
  (pcase-let* ((`(,_ ,y1 ,_ ,y2) (calendar-get-month-range)))
    (holiday-filter-visible-calendar
     (list
      (my/solar-term solar-term y1)
      (when (/= y1 y2)
        (my/solar-term solar-term y2))))))

(defconst my/holiday-other-holidays-solar-term
  '((my/holiday-solar-term "春分")
    (my/holiday-solar-term "清明")
    (my/holiday-solar-term "穀雨")
    (my/holiday-solar-term "立夏")
    (my/holiday-solar-term "小滿")
    (my/holiday-solar-term "芒種")
    (my/holiday-solar-term "夏至")
    (my/holiday-solar-term "小暑")
    (my/holiday-solar-term "大暑")
    (my/holiday-solar-term "立秋")
    (my/holiday-solar-term "處暑")
    (my/holiday-solar-term "白露")
    (my/holiday-solar-term "秋分")
    (my/holiday-solar-term "寒露")
    (my/holiday-solar-term "霜降")
    (my/holiday-solar-term "立冬")
    (my/holiday-solar-term "小雪")
    (my/holiday-solar-term "大雪")
    (my/holiday-solar-term "冬至")
    (my/holiday-solar-term "小寒")
    (my/holiday-solar-term "大寒")
    (my/holiday-solar-term "立春")
    (my/holiday-solar-term "雨水")
    (my/holiday-solar-term "驚蟄"))
  "A list of solar terms intended to be added to `holiday-other-holidays'.")

(defconst my/holiday-other-holidays-chinese-festivals
  '((holiday-chinese 1 1 "年初一")
    (holiday-chinese 1 2 "年初二")
    (holiday-chinese 1 2 "車公誕")
    (holiday-chinese 1 3 "年初三")
    (holiday-chinese 1 4 "年初四")
    (holiday-chinese 1 5 "年初五")
    (holiday-chinese 1 6 "年初六")
    (holiday-chinese 1 7 "年初七")
    (holiday-chinese 1 8 "年初八")
    (holiday-chinese 1 9 "年初九")
    (holiday-chinese 1 10 "年初十")
    (holiday-chinese 1 15 "元宵節")
    (holiday-chinese 3 23 "天后誕")
    (holiday-chinese 4 8 "佛誕")
    (holiday-chinese 4 8 "長洲太平清醮")
    (holiday-chinese 4 8 "譚公誕")
    (holiday-chinese 5 5 "端午節")
    (holiday-chinese 6 24 "關帝誔")
    (holiday-chinese 7 7 "七夕")
    (holiday-chinese 7 14 "七月十四")
    (holiday-chinese 7 15 "盂蘭節")
    (holiday-chinese 8 15 "中秋節")
    (holiday-chinese 9 9 "重陽節"))
  "A list of Chinese festivals intended to be added to `holiday-other-holidays'.")

(provide 'my-calendar)
;;; my-calendar.el ends here
