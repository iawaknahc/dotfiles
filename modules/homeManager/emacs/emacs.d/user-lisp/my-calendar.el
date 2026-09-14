;;; my-calendar.el --- my-calendar.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'calendar)
(require 'cal-julian)
(require 'cal-china)
(require 'cl-lib)
(require 'solar)
(require 'holidays)
(require 'icalendar-parser)
(require 'icalendar-ast)

(defun my/solar-longitude-local (date)
  "Invoke `solar-longitude' with DATE without binding variables."
  (solar-longitude date))

(defun my/solar-longitude-chinese (date)
  "Invoke `solar-longitude' with DATE with variables bound to Chinese timezone."
  (let* ((calendar-daylight-savings-starts nil)
         (calendar-daylight-savings-starts-time 0)
         (calendar-daylight-savings-ends nil)
         (calendar-chinese-daylight-saving-end-time 0)
         (calendar-daylight-time-offset 0)
         (calendar-time-zone 480))
    (solar-longitude date)))

(defun my/solar-date-next-longitude-chinese (date degree)
  "Invoke `solar-date-next-longitude' with DATE and DEGREE with variables bound to Chinese timezone."
  (let* ((calendar-daylight-savings-starts nil)
         (calendar-daylight-savings-starts-time 0)
         (calendar-daylight-savings-ends nil)
         (calendar-chinese-daylight-saving-end-time 0)
         (calendar-daylight-time-offset 0)
         (calendar-time-zone 480))
    (solar-date-next-longitude date degree)))

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

(defun my/astrological-sign-of-solar-longitude (longitude)
  "Return the astrological sign of LONGITUDE."
  (cl-loop
   for astrological-sign in my/astrological-signs
   for sign = (nth 0 astrological-sign)
   for lower-bound = (nth 1 astrological-sign)
   for upper-bound = (nth 2 astrological-sign)
   if (and (>= longitude lower-bound) (< longitude upper-bound)) return sign))

(defun my/astrological-sign-chinese-name (sign)
  "Return the Chinese name for SIGN."
  (when-let* ((val (alist-get sign my/astrological-signs)))
    (nth 2 val)))

(defun my/astrological-sign-string (date)
  "Display the solar longitude and the astrological sign of Gregorian date DATE."
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (julian-day-number (calendar-astro-from-absolute abs-date))
         (longitude (my/solar-longitude-local julian-day-number))
         (sign (my/astrological-sign-of-solar-longitude longitude))
         (name (my/astrological-sign-chinese-name sign)))
    (format "%s %.1f°" name longitude)))

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

(defun my/holiday-exact (month day year description)
  "Like `holiday-fixed' but with YEAR.
Return ((MONTH DAY YEAR) DESCRIPTION)"
  (holiday-filter-visible-calendar
   (list
    (list (list month day year) description))))

(defun my/holiday-saturday ()
  "It is a shorthand for (my/holiday-day-of-week 6)."
  (my/holiday-day-of-week 6 "Saturday"))

(defun my/holiday-sunday ()
  "It is a shorthand for (my/holiday-day-of-week 0)."
  (my/holiday-day-of-week 0 "Sunday"))

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

(defconst my/calendar-chinese-celestial-stem
  ["甲" "乙" "丙" "丁" "戊" "己" "庚" "辛" "壬" "癸"]
  "The names of the 10 celestial stems.")

(defconst my/calendar-chinese-terrestrial-branch
  ["子" "丑" "寅" "卯" "辰" "巳" "午" "未" "申" "酉" "戌" "亥"]
  "The names of the 12 terrestrial branches.")

(defconst my/calendar-chinese-zodiac-name-array
  ["鼠" "牛" "虎" "兔" "龍" "蛇" "馬" "羊" "猴" "雞" "狗" "豬"]
  "The names of the zodiac.")

(defconst my/calendar-chinese-month-name-array
  ["正月" "二月" "三月" "四月" "五月" "六月" "七月" "八月" "九月" "十月" "冬月" "臘月"]
  "The names of the months.")

(defconst my/calendar-chinese-day-name-array
  ["初一" "初二" "初三" "初四" "初五" "初六" "初七" "初八" "初九" "初十"
   "十一" "十二" "十三" "十四" "十五" "十六" "十七" "十八" "十九" "二十"
   "廿一" "廿二" "廿三" "廿四" "廿五" "廿六" "廿七" "廿八" "廿九" "三十"]
  "The names of the days in a month.")

(defconst my/calendar-chinese-leap-month-prefix "閏" "The prefix for the leap month.")

(defun my/calendar-chinese-sexagesimal-name (n)
  "Return the name of N in the 60-year cycle."
  (let* ((a (1- n))
         (b (mod a 10))
         (c (mod a 12))
         (d (aref my/calendar-chinese-celestial-stem b))
         (e (aref my/calendar-chinese-terrestrial-branch c)))
    (format "%s%s" d e)))

(defun my/calendar-chinese-zodiac-name (year)
  "Return the name of the zodiac of YEAR."
  (aref my/calendar-chinese-zodiac-name-array (mod (1- year) 12)))

(defun my/calendar-chinese-month-name (month)
  "Return the name of MONTH."
  (let* ((name (aref my/calendar-chinese-month-name-array (1- (floor month)))))
    (if (integerp month)
        name
      (format "%s%s" my/calendar-chinese-leap-month-prefix name))))

(defun my/calendar-chinese-day-name (day)
  "Return the name of DAY."
  (aref my/calendar-chinese-day-name-array (1- day)))

(defun my/calendar-chinese-start-year-of-cycle (date)
  "Return the start year of the cycle of Gregorian date DATE."
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (chinese-date (calendar-chinese-from-absolute abs-date))
         (cycle (calendar-extract-month chinese-date))
         (first-date-of-cycle (list cycle 1 1 1))
         (abs-date (calendar-chinese-to-absolute first-date-of-cycle))
         (date (calendar-gregorian-from-absolute abs-date)))
    (calendar-extract-year date)))

(defun my/calendar-chinese-date-string-from-gregorian (date)
  "Return the string form of Gregorian date DATE."
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (chinese-date (calendar-chinese-from-absolute abs-date))
         (cycle (nth 0 chinese-date))
         (year (nth 1 chinese-date))
         (month (nth 2 chinese-date))
         (day (nth 3 chinese-date)))
    (format
     "(循環%d %d年 始於%.4d年 肖%s) %s年%s%s"
     cycle
     year
     (my/calendar-chinese-start-year-of-cycle date)
     (my/calendar-chinese-zodiac-name year)
     (my/calendar-chinese-sexagesimal-name year)
     (my/calendar-chinese-month-name month)
     (my/calendar-chinese-day-name day))))

(defun my/calendar-iso-ordinal-date-string (date)
  "Return the string for ISO8601 ordinal date of Gregorian date DATE."
  (let* ((day-of-year (calendar-day-number date)))
    (format "%.4d-%.3d" (calendar-extract-year date) day-of-year)))

(defun my/calendar-iso-week-date-string (date)
  "Return string for ISO8601 week date of Gregorian date DATE."
  (let* ((iso-date (calendar-iso-from-absolute (calendar-absolute-from-gregorian date)))
         (year (calendar-extract-year iso-date))
         (week-number (calendar-extract-month iso-date))
         (day-number (calendar-extract-day iso-date)))
    (format "%.4d-W%.2d-%d" year week-number day-number)))

(defun my/sexagenary-day (date)
  "Return the numeric sexagenary day of Gregorian date DATE.

Borrowing the known fact stated in https://ytliu0.github.io/ChineseCalendar/sexagenary_chinese.html
Sexagenary day of DATE = 1 + mod(Julian day number - 11, 60)"
  ;; This is treated as midnight
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         ;; But Julian day number starts at noon
         (julian-day-number (calendar-astro-from-absolute abs-date))
         ;; So we need to add half day.
         (julian-day-number (floor (+ 0.5 julian-day-number))))
    (1+ (mod (- julian-day-number 11) 60))))

(defun my/sexagenary-day-string (date)
  "Return the string for the sexagenary day of Gregorian date DATE."
  (format "%s日" (my/calendar-chinese-sexagesimal-name (my/sexagenary-day date))))

(defun my/sexagenary-month-branch-1 (date)
  "Return the numeric sexagenary month branch of Gregorian date DATE.

The algorithm used here is the one used by 八字."
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (julian-day-number (calendar-astro-from-absolute abs-date))
         (longitude (my/solar-longitude-chinese julian-day-number)))
    (cond
     ;; 大雪至小寒為子月
     ((and (>= longitude 255) (< longitude 285)) 11)
     ;; 小寒至立春為丑月
     ((and (>= longitude 285) (< longitude 315)) 12)
     ;; 立春至驚蟄為寅月
     ((and (>= longitude 315) (< longitude 345)) 1)
     ;; 清明至立夏為辰月
     ((and (>= longitude 15)  (< longitude 45))  3)
     ;; 立夏至芒種為巳月
     ((and (>= longitude 45)  (< longitude 75))  4)
     ;; 芒種至小暑為午月
     ((and (>= longitude 75)  (< longitude 105)) 5)
     ;; 小暑至立秋為未月
     ((and (>= longitude 105) (< longitude 135)) 6)
     ;; 立秋至白露為申月
     ((and (>= longitude 135) (< longitude 165)) 7)
     ;; 白露至寒露為酉月
     ((and (>= longitude 165) (< longitude 195)) 8)
     ;; 白露至寒露為酉月
     ((and (>= longitude 195) (< longitude 225)) 9)
     ;; 寒露至立冬為戌月
     ((and (>= longitude 225) (< longitude 255)) 10)
     ;; 驚蟄至清明為卯月
     (t                                          2))))

(defun my/sexagenary-month-string (date)
  "Return the sexagenary month of Gregorian date DATE.

The algorithm used here is the one used by 八字."
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (chinese-date (calendar-chinese-from-absolute abs-date))
         (year (nth 1 chinese-date))
         (year-stem-1 (1+ (mod (1- year) 10)))
         (month-branch-1 (my/sexagenary-month-branch-1 date))
         (month-stem-offset-1 (pcase year-stem-1
                                ((or 1 6) 2)
                                ((or 2 7) 4)
                                ((or 3 8) 6)
                                ((or 4 9) 8)
                                ((or 5 10) 0)))
         (month-stem-1 (1+ (mod (+ (1- month-branch-1) month-stem-offset-1) 10)))
         (month-stem-0 (1- month-stem-1))
         ;; The first month is 寅月, so we have to add 2.
         (month-branch-0 (mod (+ 2 (1- month-branch-1)) 12))
         (month-stem (aref my/calendar-chinese-celestial-stem month-stem-0))
         (month-branch (aref my/calendar-chinese-terrestrial-branch month-branch-0)))
    (format "%s%s月" month-stem month-branch)))

(defun my/sexagenary-month-day-string (date)
  "Return the sexagenary month day string of Gregorian date DATE.

The algorithm used here is the one used by 八字."
  (format "%s%s" (my/sexagenary-month-string date) (my/sexagenary-day-string date)))

(defun my/calendar-gregorian-to-decode-time (date)
  "Convert Gregorian date DATE to `decode-time'."
  (list
   0 0 0
   (calendar-extract-day date) (calendar-extract-month date) (calendar-extract-year date)
   (calendar-day-of-week date) nil 0))

(defun my/calendar-gregorian-to-org-string (date)
  "Format Gregorian date DATE to a Org timestamp string."
  (format-time-string "%Y-%m-%d %a" (encode-time (my/calendar-gregorian-to-decode-time date))))

(defun my/calendar-count-days-region ()
  "A variant of `calendar-count-days-region' that prints mark and point."
  (interactive)
  (when-let* ((mark (car calendar-mark-ring))
              (cursor (calendar-cursor-to-date))
              (mark-abs (calendar-absolute-from-gregorian mark))
              (cursor-abs (calendar-absolute-from-gregorian cursor))
              (days (- cursor-abs mark-abs)))
    (let* (beg end)
      (if (< days 0)
          (progn
            (setq days (abs days))
            (setq beg cursor)
            (setq end mark))
        (setq beg mark)
        (setq end cursor))
      (setq days (1+ days))
      (message "Region [%s]--[%s] has %d days (inclusive)"
               (my/calendar-gregorian-to-org-string beg)
               (my/calendar-gregorian-to-org-string end)
               days))))

(defcustom my/calendar-business-day-holidays nil
  "A variable that works like `holiday-other-holidays' but for calculating business days."
  :type 'sexp)

(defun my/calendar-date< (date1 date2)
  "Return non-nil if DATE1 < DATE2."
  (< (calendar-absolute-from-gregorian date1) (calendar-absolute-from-gregorian date2)))

(defun my/calendar-date-within (beg end date)
  "Return non-nil if DATE >= BEG and DATE <= END."
  (cond
   ((calendar-date-equal date beg) t)
   ((calendar-date-equal date end) t)
   ((and (my/calendar-date< date end) (my/calendar-date< beg date)) t)
   (t nil)))

(defun my/calendar-business-day-holidays (beg end)
  "Return a list of holidays between Gregorian date BEG and END.

The holidays are defined in variable `my/calendar-business-day-holidays'."
  (defvar displayed-month)
  (defvar displayed-year)
  (defvar calendar-total-months)
  (let* ((beg-year (calendar-extract-year beg))
         (end-year (calendar-extract-year end))
         (holidays-in-years (cl-loop
                             for year from beg-year to end-year
                             append (let* ((calendar-total-months 12)
                                           (displayed-month 2)
                                           (displayed-year year))
                                      (cl-loop
                                       for exp in my/calendar-business-day-holidays
                                       append (eval exp t)))))
         (holidays (cl-loop
                    for holiday in holidays-in-years
                    for holiday-date = (car holiday)
                    if (my/calendar-date-within beg end holiday-date)
                    collect holiday)))
    (sort holidays :key #'car :lessp #'my/calendar-date<)))

(defun my/calendar-count-business-days-region ()
  "Print the number of business days between mark and point.

Holidays are defined by variable `my/calendar-business-day-holidays'."
  (interactive)
  (when-let* ((mark (car calendar-mark-ring))
              (cursor (calendar-cursor-to-date))
              (mark-abs (calendar-absolute-from-gregorian mark))
              (cursor-abs (calendar-absolute-from-gregorian cursor)))
    (let* (beg end beg-abs end-abs holidays holidays-hash (days 0))
      (if (< (- cursor-abs mark-abs) 0)
          (progn
            (setq beg cursor)
            (setq end mark)
            (setq beg-abs cursor-abs)
            (setq end-abs mark-abs))
        (setq beg mark)
        (setq end cursor)
        (setq beg-abs mark-abs)
        (setq end-abs cursor-abs))
      (setq holidays (my/calendar-business-day-holidays beg end))
      (setq holidays-hash (cl-loop
                           with table = (make-hash-table :test #'eql)
                           for holiday in holidays
                           for holiday-date = (car holiday)
                           for holiday-abs = (calendar-absolute-from-gregorian holiday-date)
                           do (puthash holiday-abs t table)
                           finally return table))
      (cl-loop
       for day-number from beg-abs to end-abs
       do (unless (gethash day-number holidays-hash)
            (setq days (1+ days))))
      (message "Region [%s]--[%s] has %d business days (inclusive)"
               (my/calendar-gregorian-to-org-string beg)
               (my/calendar-gregorian-to-org-string end)
               days))))

(defun my/calendar-chinese-month-day-of-year (year chinese-month chinese-day)
  "Return the Gregorian date representing CHINESE-MONTH and CHINESE-DAY in Gregorian year YEAR."
  (let* ((start-of-year (list 1 1 year))
         (start-of-year-abs (calendar-absolute-from-gregorian start-of-year))
         (start-of-year-chinese (calendar-chinese-from-absolute start-of-year-abs))
         (start-of-year-cycle (nth 0 start-of-year-chinese))
         (start-of-year-chinese-year (nth 1 start-of-year-chinese))
         (start-of-year-chinese-month (nth 2 start-of-year-chinese)))
    (setq start-of-year-chinese-year (cond
                                      ((>= start-of-year-chinese-month 7) (1+ start-of-year-chinese-year))
                                      (t start-of-year-chinese-year)))
    (when (> start-of-year-chinese-year 60)
      (setq start-of-year-chinese-year 1)
      (setq start-of-year-cycle (1+ start-of-year-cycle)))
    (calendar-gregorian-from-absolute (calendar-chinese-to-absolute (list
                                                                     start-of-year-cycle
                                                                     start-of-year-chinese-year
                                                                     chinese-month
                                                                     chinese-day)))))

(defun my/holiday-hong-kong-general-holidays-of-year-from-1999 (year)
  "Return a list of Hong Kong General Holidays in YEAR equal to or greater than 1999."
  (when (< year 1999)
    (error "Hong Kong General Holidays is only defined for year >= 1999: %d" year))
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
      (observe `(5 1 ,year) "勞動節")
      ;; Cap. 149 General Holidays Ordinance Schedule (k) the birthday of the Buddha
      (observe (my/calendar-chinese-month-day-of-year year 4 8) "佛誕")
      ;; Cap. 149 General Holidays Ordinance Schedule (l) Tuen Ng Festival
      (observe (my/calendar-chinese-month-day-of-year year 5 5) "端午節")
      ;; Cap. 149 General Holidays Ordinance Schedule (m) Hong Kong Special Administrative Region Establishment Day
      (observe `(7 1 ,year) "香港特別行政區成立紀念日")
      ;; Cap. 149 General Holidays Ordinance Schedule (n) National Day
      (observe `(10 1 ,year) "國慶日")
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
      ;; Special Holiday (3 September 2015) Ordinance
      (when (eql year 2015)
        (push (list '(9 3 2015) "[香港公眾假期] 抗日戰爭勝利七十周年紀念日") holidays)
        (puthash (calendar-absolute-from-gregorian '(9 3 2015)) t table))
      ;; 1999年第191號法律公告
      ;; https://www.elegislation.gov.hk/hk/1999/ln191
      (when (eql year 1999)
        (push (list '(12 31 1999) "[香港公眾假期] 1999年第191號法律公告所定的公眾假期") holidays)
        (puthash (calendar-absolute-from-gregorian '(12 31 1999)) t table)))
    (sort holidays :key #'car :lessp #'my/calendar-date<)))

;;;###autoload
(cl-defun my/holiday-other-holidays-hong-kong-general-holidays (&key strict)
  "An s-expression intended to be added to `holiday-other-holidays'.

When STRICT is non-nil, error if holidays cannot be derived."
  (pcase-let* ((`(,_ ,y1 ,_ ,y2) (calendar-get-month-range)))
    (when (and strict (or (< y1 1999) (< y2 1999)))
      (error "Hong Kong General Holidays cannot be derived for %d or %d" y1 y2))
    (holiday-filter-visible-calendar
     (append
      (when (>= y1 1999)
        (my/holiday-hong-kong-general-holidays-of-year-from-1999 y1))
      (when (and (>= y2 1999) (/= y1 y2))
        (my/holiday-hong-kong-general-holidays-of-year-from-1999 y2))
      nil))))

(provide 'my-calendar)
;;; my-calendar.el ends here
