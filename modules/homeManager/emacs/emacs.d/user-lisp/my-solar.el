;;; my-solar.el --- my-solar.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; `calendar-daylight-savings-starts'
;; `calendar-daylight-savings-starts-time'
;; `calendar-daylight-savings-ends'
;; `calendar-daylight-time-offset'
;; `calendar-time-zone'
(require 'cal-dst)
;; `calendar-chinese-daylight-saving-end-time'
(require 'cal-china)
;; `calendar-absolute-from-gregorian'
;; `calendar-gregorian-from-absolute'
;; `calendar-get-month-range'
(require 'calendar)
;; `calendar-astro-from-absolute'
(require 'cal-julian)
;; `holiday-filter-visible-calendar'
(require 'holidays)
;; `solar-longitude'
;; `solar-date-next-longitude'
(require 'solar)

(defconst my/astrological-signs
  '((aries 0 30 "白羊座")
    (taurus 30 60 "金牛座")
    (gemini 60 90 "雙子座")
    (cancer 90 120 "巨蟹座")
    (leo 120 150 "獅子座")
    (virgo 150 180 "處女座")
    (libra 180 210 "天秤座")
    (scorpio 210 240 "天蠍座")
    (sagittarius 240 270 "人馬座")
    (capricorn 270 300 "山羊座")
    (aquarius 300 330 "水瓶座")
    (pisces 330 360 "雙魚座"))
  "The list of Astrological signs.

The first element is the name of the sign.
The second element is the start degree, inclusive.
The third element is the end degree, exclusive.
The fourth element is the Chinese name.")

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

;;;###autoload
(defun my/solar-longitude-local (date)
  "Invoke `solar-longitude' with DATE without binding variables."
  (solar-longitude date))

;;;###autoload
(defun my/solar-longitude-chinese (date)
  "Invoke `solar-longitude' with DATE with variables bound to Chinese timezone."
  (let* ((calendar-daylight-savings-starts nil)
         (calendar-daylight-savings-starts-time 0)
         (calendar-daylight-savings-ends nil)
         (calendar-chinese-daylight-saving-end-time 0)
         (calendar-daylight-time-offset 0)
         (calendar-time-zone 480))
    (solar-longitude date)))

;;;###autoload
(defun my/solar-date-next-longitude-chinese (date degree)
  "Invoke `solar-date-next-longitude' with DATE and DEGREE with variables bound to Chinese timezone."
  (let* ((calendar-daylight-savings-starts nil)
         (calendar-daylight-savings-starts-time 0)
         (calendar-daylight-savings-ends nil)
         (calendar-chinese-daylight-saving-end-time 0)
         (calendar-daylight-time-offset 0)
         (calendar-time-zone 480))
    (solar-date-next-longitude date degree)))

;;;###autoload
(defun my/astrological-sign-of-solar-longitude (longitude)
  "Return the astrological sign of LONGITUDE."
  (cl-loop
   for astrological-sign in my/astrological-signs
   for sign = (nth 0 astrological-sign)
   for lower-bound = (nth 1 astrological-sign)
   for upper-bound = (nth 2 astrological-sign)
   if (and (>= longitude lower-bound) (< longitude upper-bound)) return sign))

;;;###autoload
(defun my/astrological-sign-chinese-name (sign)
  "Return the Chinese name for SIGN."
  (when-let* ((val (alist-get sign my/astrological-signs)))
    (nth 2 val)))

;;;###autoload
(defun my/astrological-sign-string (date)
  "Display the solar longitude and the astrological sign of Gregorian date DATE."
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (julian-day-number (calendar-astro-from-absolute abs-date))
         (longitude (my/solar-longitude-local julian-day-number))
         (sign (my/astrological-sign-of-solar-longitude longitude))
         (name (my/astrological-sign-chinese-name sign)))
    (format "%s %5.1f°" name longitude)))

;;;###autoload
(defun my/solar-term (solar-term year &optional description)
  "Compute SOLAR-TERM in Gregorian YEAR.
No daylight saving is considered and the timezone is fixed to be Asia/Hong_Kong (UTC+08:00)

If DESCRIPTION is nil, a suitable description is generated.

Return ((month day year) DESCRIPTION).
The return value can be used directly as a holiday."
  ;; Return nil if solar-term is invalid
  (when-let* ((val (alist-get solar-term my/solar-terms nil nil #'string=)))
    ;; Destructure val.
    (let* ((month-day (cadr val))
           (month (car month-day))
           (day (cadr month-day))
           ;; Subtract 2 days from the typical day so that we will never overshoot.
           (start (list month (- day 2) year))
           ;; Convert `start' to absolute date.
           (start-abs (calendar-absolute-from-gregorian start))
           ;; Convert absolute date to Julian date.
           (start-astro (calendar-astro-from-absolute start-abs))
           ;; Call `my/solar-date-next-longitude-chinese' to do the heavy lifting.
           (result-astro (my/solar-date-next-longitude-chinese start-astro 15))
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
      (list result-gregorian-date (or description holiday-description)))))

;;;###autoload
(defun my/holiday-solar-term (solar-term &optional description)
  "An s-expression intended to be added to `holiday-other-holidays'.
Compute the holiday for SOLAR-TERM and DESCRIPTION."
  (pcase-let* ((`(,_ ,y1 ,_ ,y2) (calendar-get-month-range)))
    (holiday-filter-visible-calendar
     (list
      (my/solar-term solar-term y1 description)
      (when (/= y1 y2)
        (my/solar-term solar-term y2 description))))))

(provide 'my-solar)
;;; my-solar.el ends here
