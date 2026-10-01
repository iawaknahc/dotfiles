;;; my-holidays.el --- my-holidays.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; `calendar-get-date-range'
;; `calendar-absolute-from-gregorian'
;; `calendar-gregorian-from-absolute'
;; `calendar-day-of-week'
(require 'calendar)

;;;###autoload
(defun my/holiday-day-of-week (day-of-week description)
  "A `holiday-other-holidays' s-expression to make DAY-OF-WEEK a holiday with DESCRIPTION."
  (pcase-let* ((`(,beg . ,end) (calendar-get-date-range t)))
    (let* ((beg-abs (calendar-absolute-from-gregorian beg))
           (end-abs (calendar-absolute-from-gregorian end)))
      (cl-loop
       for day-number from beg-abs to end-abs
       for gregorian = (calendar-gregorian-from-absolute day-number)
       if (equal day-of-week (calendar-day-of-week gregorian))
       collect (list gregorian description)))))

;;;###autoload
(defun my/holiday-saturday ()
  "It is a shorthand for (my/holiday-day-of-week 6)."
  (my/holiday-day-of-week 6 "Saturday"))

;;;###autoload
(defun my/holiday-sunday ()
  "It is a shorthand for (my/holiday-day-of-week 0)."
  (my/holiday-day-of-week 0 "Sunday"))

;;;###autoload
(defun my/holiday-hong-kong-general-holidays-of-year-from-1997 (year)
  "Return a list of Hong Kong General Holidays in YEAR equal to or greater than 1997."
  (when (< year 1997)
    (error "Hong Kong General Holidays is only defined for year >= 1997: %d" year))
  (let* ((table (make-hash-table :test #'eql))
         (easter-abs (holiday-easter-etc-abs year))
         holidays)
    ;; Cap. 149 General Holidays Ordinance Schedule (a) every Sunday
    (cl-loop
     for day-number from (calendar-absolute-from-gregorian `(1 1 ,year)) to (calendar-absolute-from-gregorian `(12 31 ,year))
     for date = (calendar-gregorian-from-absolute day-number)
     if (eql (calendar-day-of-week date) 0)
     do (puthash day-number t table))
    (cl-labels ((observe (date description &optional in-lieu-offset in-lieu-description)
                  (let* ((day-number (calendar-absolute-from-gregorian date)))
                    (if (gethash day-number table)
                        (let* ((day-number (+ day-number (or in-lieu-offset 1)))
                               (date (calendar-gregorian-from-absolute day-number)))
                          (puthash day-number t table)
                          (push (list date (format "[香港公眾假期] %s" (or in-lieu-description (concat description "翌日")))) holidays))
                      (puthash day-number t table)
                      (push (list date (format "[香港公眾假期] %s" description)) holidays)))))
      ;; Cap. 149 General Holidays Ordinance Schedule (b) the first day of January
      (observe `(1 1 ,year) "一月一日")
      ;; Cap. 149 General Holidays Ordinance Schedule (c), (d), (e) the first three days of Lunar New year
      (cond
       ((>= year 2011)
        (observe (my/calendar-chinese-month-day-of-year year 1 1) "農曆年初一" 3 "農曆年初四")
        (observe (my/calendar-chinese-month-day-of-year year 1 2) "農曆年初二" 2 "農曆年初四")
        (observe (my/calendar-chinese-month-day-of-year year 1 3) "農曆年初三" 1 "農曆年初四"))
       (t
        (observe (my/calendar-chinese-month-day-of-year year 1 1) "農曆年初一" -1 "農曆年初一的前一日")
        (observe (my/calendar-chinese-month-day-of-year year 1 2) "農曆年初二" -2 "農曆年初一的前一日")
        (observe (my/calendar-chinese-month-day-of-year year 1 3) "農曆年初三" -3 "農曆年初一的前一日")))
      ;; Cap. 149 General Holidays Ordinance Schedule (f) Ching Ming Festival
      (observe (car (my/solar-term "清明" year)) "清明節")
      ;; Cap. 149 General Holidays Ordinance Schedule (g) Good Friday
      ;; Cap. 149 General Holidays Ordinance Schedule (h) the day following Good Friday
      ;; Cap. 149 General Holidays Ordinance Schedule (i) Easter Monday
      (observe (calendar-gregorian-from-absolute (- easter-abs 2)) "耶穌受難節" 4 "復活節星期一翌日")
      (observe (calendar-gregorian-from-absolute (- easter-abs 1)) "耶穌受難節翌日" 3 "復活節星期一翌日")
      (observe (calendar-gregorian-from-absolute (+ easter-abs 1)) "復活節星期一" 1 "復活節星期一翌日")
      ;; Cap. 149 General Holidays Ordinance Schedule (j) Labor day
      (when (>= year 1999)
        (observe `(5 1 ,year) "勞動節"))
      ;; Cap. 149 General Holidays Ordinance Schedule (k) the birthday of the Buddha
      (when (>= year 1999)
        (observe (my/calendar-chinese-month-day-of-year year 4 8) "佛誕"))
      ;; Cap. 149 General Holidays Ordinance Schedule (l) Tuen Ng Festival
      (observe (my/calendar-chinese-month-day-of-year year 5 5) "端午節")
      (when (eql year 1997)
        ;; 1996年第294號法律公告
        ;; https://www.elegislation.gov.hk/hk/1996/ln294!en
        (observe '(6 28 1997) "英女皇壽辰")
        ;; Cap. 149 General Holidays Ordinance Schedule (l) the Monday following the birthday of Her Majesty The Queen (1997)
        (observe '(6 30 1997) "英女皇壽辰後第一個星期一"))
      ;; Cap. 149 General Holidays Ordinance Schedule (m) Hong Kong Special Administrative Region Establishment Day
      (observe `(7 1 ,year) "香港特別行政區成立紀念日")
      ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 2
      ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
      (when (eql year 1997)
        (observe '(7 2 1997) "香港特別行政區成立日翌日"))
      ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 3
      ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
      (when (eql year 1998)
        (observe '(8 17 1998) "抗日戰爭勝利紀念日"))
      ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 2
      ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
      (when (eql year 1997)
        (observe '(8 18 1997) "抗日戰爭勝利紀念日"))
      ;; Special Holiday (3 September 2015) Ordinance
      (when (eql year 2015)
        (observe '(9 3 2015) "抗日戰爭勝利七十周年紀念日"))
      ;; Cap. 149 General Holidays Ordinance Schedule (n) National Day
      (observe `(10 1 ,year) "國慶日")
      ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 2
      ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
      (when (eql year 1997)
        (observe '(10 2 1997) "國慶日翌日"))
      ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 3
      ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
      (when (eql year 1998)
        (observe '(10 2 1998) "國慶日翌日"))
      ;; Cap. 149 General Holidays Ordinance Schedule (o) the day following the Chinese Mid-Autumn Festival
      (cond
       ((>= year 2011)
        (observe (my/calendar-chinese-month-day-of-year year 8 16) "中秋節翌日" 1 "中秋節後第二日"))
       (t
        (observe (my/calendar-chinese-month-day-of-year year 8 16) "中秋節翌日" -1 "中秋節")))
      ;; Cap. 149 General Holidays Ordinance Schedule (p) Chung Yeung Festival
      (observe (my/calendar-chinese-month-day-of-year year 9 9) "重陽節")
      ;; Cap. 149 General Holidays Ordinance Schedule (q) Christmas Day
      ;; Cap. 149 General Holidays Ordinance Schedule (r) the first weekday after Christmas Day
      ;; If Christmas Day is a Sunday, then 12-27 is a Tuesday,
      ;; so the in-lieu description is the second weekday after Christmas Day.
      (observe `(12 25 ,year) "聖誕節" 2 "聖誕節後第二個周日")
      ;; If 12-26 is a Sunday, then 12-27 is a Monday,
      ;; so in either case, the description is still the first weekday after Christmas Day.
      (observe `(12 26 ,year) "聖誕節後第一個周日" 1 "聖誕節後第一個周日")
      ;; 1999年第191號法律公告
      ;; https://www.elegislation.gov.hk/hk/1999/ln191
      (when (eql year 1999)
        (observe '(12 31 1999) "1999年第191號法律公告所定的公眾假期")))
    (sort holidays :key #'car :lessp #'my/calendar-date<)))

;;;###autoload
(cl-defun my/holiday-other-holidays-hong-kong-general-holidays (&key strict)
  "An s-expression intended to be added to `holiday-other-holidays'.

When STRICT is non-nil, error if holidays cannot be derived."
  (pcase-let* ((`(,_ ,y1 ,_ ,y2) (calendar-get-month-range)))
    (when (and strict (or (< y1 1997) (< y2 1997)))
      (error "Hong Kong General Holidays cannot be derived for %d or %d" y1 y2))
    (holiday-filter-visible-calendar
     (append
      (when (>= y1 1997)
        (my/holiday-hong-kong-general-holidays-of-year-from-1997 y1))
      (when (and (>= y2 1997) (/= y1 y2))
        (my/holiday-hong-kong-general-holidays-of-year-from-1997 y2))
      nil))))

(provide 'my-holidays)
;;; my-holidays.el ends here
