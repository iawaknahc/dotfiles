;;; my-cal-china.el --- my-cal-china.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; `holiday-chinese'
;; `calendar-chinese-from-absolute'
;; `calendar-chinese-to-absolute'
(require 'cal-china)
;; `calendar-astro-from-absolute'
(require 'cal-julian)
;; `calendar-absolute-from-gregorian'
;; `calendar-gregorian-from-absolute'
;; `calendar-extract-month'
(require 'calendar)

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

(defconst my/calendar-chinese-leap-month-prefix
  "閏"
  "The prefix for the leap month.")

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

;;;###autoload
(defun my/calendar-chinese-sexagesimal-name (n)
  "Return the name of N in the 60-year cycle."
  (let* ((a (1- n))
         (b (mod a 10))
         (c (mod a 12))
         (d (aref my/calendar-chinese-celestial-stem b))
         (e (aref my/calendar-chinese-terrestrial-branch c)))
    (format "%s%s" d e)))

;;;###autoload
(defun my/calendar-chinese-zodiac-name (year)
  "Return the name of the zodiac of YEAR."
  (aref my/calendar-chinese-zodiac-name-array (mod (1- year) 12)))

;;;###autoload
(defun my/calendar-chinese-month-name (month)
  "Return the name of MONTH."
  (let* ((name (aref my/calendar-chinese-month-name-array (1- (floor month)))))
    (if (integerp month)
        name
      (format "%s%s" my/calendar-chinese-leap-month-prefix name))))

;;;###autoload
(defun my/calendar-chinese-day-name (day)
  "Return the name of DAY."
  (aref my/calendar-chinese-day-name-array (1- day)))

;;;###autoload
(defun my/calendar-chinese-start-year-of-cycle (date)
  "Return the start year of the cycle of Gregorian date DATE."
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (chinese-date (calendar-chinese-from-absolute abs-date))
         (cycle (calendar-extract-month chinese-date))
         (first-date-of-cycle (list cycle 1 1 1))
         (abs-date (calendar-chinese-to-absolute first-date-of-cycle))
         (date (calendar-gregorian-from-absolute abs-date)))
    (calendar-extract-year date)))

;;;###autoload
(defun my/calendar-chinese-date-string-from-gregorian (date)
  "Return the string form of Gregorian date DATE."
  (let* ((abs-date (calendar-absolute-from-gregorian date))
         (chinese-date (calendar-chinese-from-absolute abs-date))
         (cycle (nth 0 chinese-date))
         (year (nth 1 chinese-date))
         (month (nth 2 chinese-date))
         (day (nth 3 chinese-date)))
    (format
     "(循環%d %2d年 始於%04d年 肖%s) %s年%s%s"
     cycle
     year
     (my/calendar-chinese-start-year-of-cycle date)
     (my/calendar-chinese-zodiac-name year)
     (my/calendar-chinese-sexagesimal-name year)
     (my/calendar-chinese-month-name month)
     (my/calendar-chinese-day-name day))))

;;;###autoload
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

;;;###autoload
(defun my/sexagenary-day-string (date)
  "Return the string for the sexagenary day of Gregorian date DATE."
  (format "%s日" (my/calendar-chinese-sexagesimal-name (my/sexagenary-day date))))

;;;###autoload
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

;;;###autoload
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

;;;###autoload
(defun my/sexagenary-month-day-string (date)
  "Return the sexagenary month day string of Gregorian date DATE.

The algorithm used here is the one used by 八字."
  (format "%s%s" (my/sexagenary-month-string date) (my/sexagenary-day-string date)))

(provide 'my-cal-china)
;;; my-cal-china.el ends here
