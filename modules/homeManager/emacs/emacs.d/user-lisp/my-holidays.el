;;; my-holidays.el --- my-holidays.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; `calendar-get-date-range'
;; `calendar-absolute-from-gregorian'
;; `calendar-gregorian-from-absolute'
;; `calendar-day-of-week'
(require 'calendar)

(require 'cl-lib)

;; `my/calendar-date<'
(require 'my-calendar)

;; `my/calendar-chinese-anniversary'
(require 'my-cal-china)

;; `my/holiday-solar-term'
(require 'my-solar)

;;;###autoload
(defun my/holiday-get-years ()
  "Return a singleton list or a 2-element list."
  (pcase-let* ((`(_ ,y1 _ ,y2) (calendar-get-month-range)))
    (if (eql y1 y2)
        (list y1)
      (list y1 y2))))

;;;###autoload
(defun my/holiday--pad-years (years)
  "Add two more years to YEARS."
  (let* ((a (1- (car years)))
         (b (1+ (car (last years)))))
    (append (list a)
            years
            (list b)
            nil)))

;;;###autoload
(cl-defmacro my/holiday-bind (expr &key year month)
  "Surround EXPR with `displayed-year' bound to YEAR and `displayed-month' bound to MONTH.

If YEAR is nil, then it is assumed to be the current year.

If MONTH is nil, then it is assumed to be 2 and `calendar-total-months' is bound to 12,
resulting in `calendar-get-month-range' reporting all months in YEAR."
  `(funcall (lambda ()
              (defvar displayed-year)
              (defvar displayed-month)
              (defvar calendar-total-months)
              (let* ((year ,year)
                     (month ,month)
                     (current-date (calendar-current-date))
                     (calendar-total-months calendar-total-months)
                     displayed-year
                     displayed-month)
                (unless year
                  (setq year (calendar-extract-year current-date)))
                (unless month
                  (setq month 2)
                  (setq calendar-total-months 12))
                (setq displayed-year year)
                (setq displayed-month month)
                ,expr))))

;;;###autoload
(defun my/holiday-forms-to-hlist (forms)
  "Evaluate FORMS and concatenate the result into a single holiday list."
  (seq-mapcat (lambda (form) (eval form t)) forms))

;;;###autoload
(defun my/holiday-sort (holidays)
  "Sort HOLIDAYS."
  (sort holidays :key #'car :lessp #'my/calendar-date<))

;;;###autoload
(defmacro my/holiday-diary (expr)
  "Use holiday expression EXPR as a diary sexp.

Functions like `holiday-fixed' need `displayed-year' and `displayed-month',
but they are not bound when a diary sexp is evaluated.
A diary sexp is evaluated with `date' bound instead, and is expected to return a string or nil."
  `(progn
     (with-no-warnings (defvar date))
     (let* ((year (calendar-extract-year date))
            (month (calendar-extract-month date))
            (holidays (my/holiday-bind ,expr :year year :month month))
            (holidays (seq-filter (lambda (holiday)
                                    (calendar-date-equal (car holiday) date))
                                  holidays)))
       (when holidays
         (mapconcat #'cadr holidays "; ")))))

;;;###autoload
(defun my/holiday-anniversary (year month day description)
  "A `holiday-other-holidays' s-expression for anniversary on YEAR MONTH DAY with DESCRIPTION."
  (pcase-let* ((`(_ ,y1 _ ,y2) (calendar-get-month-range)))
    (let* ((y1-instance (list month day y1))
           (y2-instance (list month day y2))
           (y1-instance-nth (- y1 year))
           (y2-instance-nth (- y2 year))
           result)
      (when (>= y1-instance-nth 0)
        (setq result (append result (list (list y1-instance (format "%s %d周年" description y1-instance-nth))) nil)))
      (when (and (>= y2-instance-nth 0) (/= y1-instance-nth y2-instance-nth))
        (setq result (append result (list (list y2-instance (format "%s %d周年" description y1-instance-nth))) nil)))
      (holiday-filter-visible-calendar result))))

;;;###autoload
(defun my/holiday-exact (year month day description)
  "A `holiday-other-holidays' s-expression for date ON YEAR MONTH DAY with DESCRIPTION."
  (holiday-filter-visible-calendar (list (list (list month day year) description))))

;;;###autoload
(defun my/holiday-easter (offset description)
  "A `holiday-other-holidays' s-expression for Easter with OFFSET and DESCRIPTION.
`holiday-easter-etc-abs' is used to calculate Easter.

For example, an OFFSET of -2 is Good Friday,
an OFFSET of -1 is Holy Saturday,
an OFFSET of 0 is Easter Sunday,
an OFFSET of 1 is Easter Monday."
  (pcase-let* ((`(_ ,y1 _ ,y2) (calendar-get-month-range)))
    (let* ((y1-abs (holiday-easter-etc-abs y1))
           (y2-abs (holiday-easter-etc-abs y2))
           (y1-abs (+ y1-abs offset))
           (y2-abs (+ y2-abs offset))
           (y1-date (calendar-gregorian-from-absolute y1-abs))
           (y2-date (calendar-gregorian-from-absolute y2-abs))
           result)
      (setq result (append result (list (list y1-date description)) nil))
      (when (/= y1-abs y2-abs)
        (setq result (append result (list (list y2-date description)) nil)))
      (holiday-filter-visible-calendar result))))

;;;###autoload
(defun my/holiday-prefix (prefix hlist)
  "A `holiday-other-holidays' s-expression to add PREFIX to the description of holidays in HLIST."
  (seq-map (lambda (holiday)
             (list (car holiday) (format "%s%s" prefix (cadr holiday))))
           hlist))

;;;###autoload
(defun my/holiday-substitution (hlist offset description)
  "Define a substitution for the first element in HLIST.

HLIST must either be an empty list, or a singleton list.

The substitution is determined by converting the element to an absolute date,
and add OFFSET to it.
OFFSET, therefore, must be an integer, either positive or negative, but not zero.

DESCRIPTION will be used as the description of the substitution."
  (pcase hlist
    ('nil
     nil)
    (`((,date ,desc))
     (let* ((date-abs (calendar-absolute-from-gregorian date))
            (substitution-abs (+ date-abs offset))
            (substitution (calendar-gregorian-from-absolute substitution-abs)))
       (list (list date desc) (list substitution description))))
    (_
     (error "Expected HLIST to be an empty list or a singleton list: %S" hlist))))

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

(defconst my/holiday-hong-kong-sundays
  '((my/holiday-sunday))
  "A `holiday-other-holidays' like variable to define Sundays.")

(defconst my/holiday-hong-kong-general-holidays
  '(;; Cap. 149 General Holidays Ordinance Schedule (b) the first day of January
    (my/holiday-substitution (holiday-fixed 1 1 "一月一日") 1 "一月一日翌日")
    ;; Cap. 149 General Holidays Ordinance Schedule (c), (d), (e) the first three days of Lunar New year
    (if (>= displayed-year 2011)
        (my/holiday-substitution (holiday-chinese 1 1 "農曆年初一") 3 "農曆年初四")
      (my/holiday-substitution (holiday-chinese 1 1 "農曆年初一") -1 "農曆年初一的前一日"))
    (if (>= displayed-year 2011)
        (my/holiday-substitution (holiday-chinese 1 2 "農曆年初二") 2 "農曆年初四")
      (my/holiday-substitution (holiday-chinese 1 2 "農曆年初二") -2 "農曆年初一的前一日"))
    (if (>= displayed-year 2011)
        (my/holiday-substitution (holiday-chinese 1 3 "農曆年初三") 1 "農曆年初四")
      (my/holiday-substitution (holiday-chinese 1 3 "農曆年初三") -3 "農曆年初一的前一日"))
    ;; Cap. 149 General Holidays Ordinance Schedule (f) Ching Ming Festival
    (my/holiday-substitution (my/holiday-solar-term "清明" "清明節") 1 "清明節翌日")
    ;; Cap. 149 General Holidays Ordinance Schedule (g) Good Friday
    ;; Cap. 149 General Holidays Ordinance Schedule (h) the day following Good Friday
    ;; Cap. 149 General Holidays Ordinance Schedule (i) Easter Monday
    (my/holiday-substitution (my/holiday-easter -2 "耶穌受難節") 4 "復活節星期一翌日")
    (my/holiday-substitution (my/holiday-easter -1 "耶穌受難節翌日") 3 "復活節星期一翌日")
    (my/holiday-substitution (my/holiday-easter 1 "復活節星期一") 1 "復活節星期一翌日")
    ;; Cap. 149 General Holidays Ordinance Schedule (j) Labor day
    (when (>= displayed-year 1999)
      (my/holiday-substitution (holiday-fixed 5 1 "勞動節") 1 "勞動節翌日"))
    ;; Cap. 149 General Holidays Ordinance Schedule (k) the birthday of the Buddha
    (when (>= displayed-year 1999)
      (my/holiday-substitution (holiday-chinese 4 8 "佛誕") 1 "佛誕翌日"))
    ;; Cap. 149 General Holidays Ordinance Schedule (l) Tuen Ng Festival
    (my/holiday-substitution (holiday-chinese 5 5 "端午節") 1 "端午節翌日")
    ;; 1996年第294號法律公告
    ;; https://www.elegislation.gov.hk/hk/1996/ln294!en
    (my/holiday-exact 1997 6 28 "英女皇壽辰")
    ;; Cap. 149 General Holidays Ordinance Schedule (l) the Monday following the birthday of Her Majesty The Queen (1997)
    (my/holiday-exact 1997 6 30 "英女皇壽辰後第一個星期一")
    ;; Cap. 149 General Holidays Ordinance Schedule (m) Hong Kong Special Administrative Region Establishment Day
    (my/holiday-substitution (holiday-fixed 7 1 "香港特別行政區成立紀念日") 1  "香港特別行政區成立紀念日翌日")
    ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 2
    ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
    (my/holiday-exact 1997 7 2 "香港特別行政區成立日翌日")
    ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 3
    ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
    (my/holiday-exact 1998 8 17 "抗日戰爭勝利紀念日")
    ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 2
    ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
    (my/holiday-exact 1997 8 18 "抗日戰爭勝利紀念日")
    ;; Special Holiday (3 September 2015) Ordinance
    (my/holiday-exact 2015 9 3 "抗日戰爭勝利七十周年紀念日")
    ;; Cap. 149 General Holidays Ordinance Schedule (n) National Day
    (my/holiday-substitution (holiday-fixed 10 1 "國慶日") 1  "國慶日翌日")
    ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 2
    ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
    (my/holiday-exact 1997 10 2 "國慶日翌日")
    ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 3
    ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
    (my/holiday-exact 1998 10 2 "國慶日翌日")
    ;; Cap. 149 General Holidays Ordinance Schedule (o) the day following the Chinese Mid-Autumn Festival
    (if (>= displayed-year 2011)
        (my/holiday-substitution (holiday-chinese 8 16 "中秋節翌日") 1 "中秋節後第二日")
      (my/holiday-substitution (holiday-chinese 8 16 "中秋節翌日") -1 "中秋節"))
    ;; Cap. 149 General Holidays Ordinance Schedule (p) Chung Yeung Festival
    (my/holiday-substitution (holiday-chinese 9 9 "重陽節") 1 "重陽節翌日")
    ;; Cap. 149 General Holidays Ordinance Schedule (q) Christmas Day
    ;; Cap. 149 General Holidays Ordinance Schedule (r) the first weekday after Christmas Day
    ;; If Christmas Day is a Sunday, then 12-27 is a Tuesday,
    ;; so the description of substitution is the second weekday after Christmas Day.
    (my/holiday-substitution (holiday-fixed 12 25 "聖誕節") 2 "聖誕節後第二個周日")
    ;; If 12-26 is a Sunday, then 12-27 is a Monday,
    ;; so in either case, the description is still the first weekday after Christmas Day.
    (my/holiday-substitution (holiday-fixed 12 26 "聖誕節後第一個周日") 1 "聖誕節後第一個周日")
    ;; 1999年第191號法律公告
    ;; https://www.elegislation.gov.hk/hk/1999/ln191
    (my/holiday-exact 1999 12 31 "1999年第191號法律公告所定的公眾假期"))
  "A `holiday-other-holidays' like variables to define Hong Kong General Holidays.")

(defconst my/holiday-hong-kong-statutory-holidays
  '(;; Cap. 57 Section 39(1)(a) Lunar New Year’s Day
    (if (>= displayed-year 2011)
        (my/holiday-substitution (holiday-chinese 1 1 "農曆年初一") 3 "農曆年初四")
      (my/holiday-substitution (holiday-chinese 1 1 "農曆年初一") -1 "農曆年初一的前一日"))
    ;; Cap. 57 Section 39(1)(a) the second day of Lunar New Year
    (if (>= displayed-year 2011)
        (my/holiday-substitution (holiday-chinese 1 2 "農曆年初二") 2 "農曆年初四")
      (my/holiday-substitution (holiday-chinese 1 2 "農曆年初二") -2 "農曆年初一的前一日"))
    ;; Cap. 57 Section 39(1)(c) the third day of Lunar New Year
    (if (>= displayed-year 2011)
        (my/holiday-substitution (holiday-chinese 1 3 "農曆年初三") 1 "農曆年初四")
      (my/holiday-substitution (holiday-chinese 1 3 "農曆年初三") -3 "農曆年初一的前一日"))
    ;; Cap. 57 Section 39(1)(d) Ching Ming Festival
    (my/holiday-solar-term "清明" "清明節")
    ;; Cap. 57 Section 39(1)(da) Labor Day
    ;; Cap. 57 Section 39(1A) says 39(1)(da) is suspended for 1998.
    (when (>= displayed-year 1999)
      (holiday-fixed 5 1 "勞動節"))
    ;; Cap. 57 Section 39(1)(e) Tuen Ng Festival
    (holiday-chinese 5 5 "端午節")
    ;; Cap. 57 Section 39(1)(f) the day following the Chinese Mid-Autumn Festival
    (if (>= displayed-year 2011)
        (my/holiday-substitution (holiday-chinese 8 16 "中秋節翌日") 1 "中秋節後第二日")
      (my/holiday-substitution (holiday-chinese 8 16 "中秋節翌日") -1 "中秋節"))
    ;; Cap. 57 Section 39(1)(g) Chung Yeung Festival
    (holiday-chinese 9 9 "重陽節")
    ;; Cap. 57 Section 39(1)(h) the Chinese Winter Solstice Festival or Christmas Day
    (my/holiday-solar-term "冬至" "冬節或聖誕節")
    (holiday-fixed 12 25 "冬節或聖誕節")
    ;; Cap. 57 Section 39(1)(i) the first day of January
    (holiday-fixed 1 1 "1月1日")
    ;; Cap. 57 Section 39(1)(j) Hong Kong Special Administrative Region Establishment Day
    (holiday-fixed 7 1 "香港特別行政區成立紀念日")
    ;; Cap. 534 Holidays (1997 and 1998) Ordinance Schedule 2
    ;; https://www.elegislation.gov.hk/hk/cap534!zh-Hant-HK
    (my/holiday-exact 1997 7 2 "香港特別行政區成立日翌日")
    ;; Cap. 57 Section 39(1)(k) National Day
    (holiday-fixed 10 1 "國慶日")
    ;; Cap. 57 Section 39(1)(l) the Birthday of the Buddha
    ;; 2021年第21號條例
    (when (>= displayed-year 2022)
      (holiday-chinese 4 8 "佛誕"))
    ;; Cap. 57 Section 39(1)(m) the first weekday after Christmas Day
    ;; 2021年第21號條例
    (when (>= displayed-year 2024)
      (my/holiday-substitution (holiday-fixed 12 26 "聖誕節後第一個周日") 1 "聖誕節後第一個周日"))
    ;; Cap. 57 Section 39(1)(n) Easter Monday
    ;; 2021年第21號條例
    (when (>= displayed-year 2026)
      (my/holiday-easter 1 "復活節星期一"))
    ;; Cap. 57 Section 39(1)(o) Good Friday
    ;; 2021年第21號條例
    (when (>= displayed-year 2028)
      (my/holiday-easter -2 "耶穌受難節"))
    ;; Cap. 57 Section 39(1)(p) the day following Good Friday
    ;; 2021年第21號條例
    (when (>= displayed-year 2030)
      (my/holiday-easter -1 "耶穌受難節翌日")))
  "A `holiday-other-holidays' like variables to define Hong Kong Statutory Holidays.")

(cl-defun my/holiday-hong-kong (holidays &key strict)
  "Return a list of holidays derived algorithmically for year >= 1997.
If STRICT is non-nil and year is < 1997, throw an error.

The return value is controlled HOLIDAYS.

To compute a list of Hong Kong General Holidays,
pass `my/holiday-hong-kong-general-holidays'.

To compute a list of Hong Kong Statutory Holidays,
pass `my/holiday-hong-kong-statutory-holidays'.

Each expression in HOLIDAYS should evaluate to
an empty list, a singleton list, or a 2-element list.

When it is an empty list, it is ignored.

When it is a singleton list, it is treated as a holiday without substitution.
Typically there are two cases.
The first case is a holiday with an exact date, as declared by law.
In this case, the function `my/holiday-exact' is used to define such holiday.
The second case is a statutory holiday without substitution rule.
For example, Chung Yeung Festival has no substitution rule.

When it is a 2-element list, the first element is the holiday and the second element is the substitution.
When the holiday clashes with a previous holiday in the same year, the substitution is used.
The function `my/holiday-substitution' is used to define such holiday."
  (let* ((table (make-hash-table :test #'eql))
         result)
    (dolist (year (my/holiday-get-years))
      ;; Respect strictness
      (when (and strict (< year 1997))
        (error "Only year greater than or equal to 1997 is supported: %S" year))

      (when (>= year 1997)
        ;; Fill in the table with Sundays first.
        (dolist (form my/holiday-hong-kong-sundays)
          (dolist (holiday (my/holiday-bind (eval form) :year year))
            (let* ((date-abs (calendar-absolute-from-gregorian (car holiday))))
              (puthash date-abs t table))))

        (dolist (form holidays)
          (let* ((holiday-and-substitution (my/holiday-bind (eval form) :year year)))
            (pcase holiday-and-substitution
              ('nil nil)
              (`(,holiday)
               (let* ((holiday-abs (calendar-absolute-from-gregorian (car holiday))))
                 (puthash holiday-abs t table)
                 (push holiday result)))
              (`(,holiday ,substitution)
               (let* ((holiday-abs (calendar-absolute-from-gregorian (car holiday)))
                      (substitution-abs (calendar-absolute-from-gregorian (car substitution))))
                 (if (gethash holiday-abs table)
                     (progn
                       (puthash substitution-abs t table)
                       (push substitution result))
                   (puthash holiday-abs t table)
                   (push holiday result))))
              (_ (error "Expected an empty list or a singleton list or a 2-element list: %S" holiday-and-substitution)))))))
    (holiday-filter-visible-calendar (my/holiday-sort result))))

(defun my/holiday-chinese--birth (name birth)
  "NAME BIRTH."
  (let* ((years (my/holiday-get-years))
         (years (my/holiday--pad-years years))
         (anniversaries (seq-map (lambda (year)
                                   (my/calendar-chinese-anniversary birth year))
                                 years))
         (anniversaries (seq-filter (lambda (plist)
                                      (>= (plist-get plist :order) 0))
                                    anniversaries))
         (anniversaries (seq-map (lambda (plist)
                                   (let* ((date (plist-get plist :anniversary-gregorian))
                                          (order (plist-get plist :order))
                                          (description (cond
                                                        ((eql order 0)
                                                         (format "%s 農曆出世" name))
                                                        (t
                                                         (format "%s %d歲農曆生日" name order)))))
                                     (list date description)))
                                 anniversaries)))
    (holiday-filter-visible-calendar anniversaries)))

(defun my/holiday-chinese--birth-and-death (name birth death)
  "NAME BIRTH DEATH."
  (let* ((years (my/holiday-get-years))
         (years (my/holiday--pad-years years))
         (death-abs (calendar-absolute-from-gregorian death))
         (ref (lambda (_year) death-abs))
         (birth-anniversaries (seq-map (lambda (year)
                                         (my/calendar-chinese-anniversary birth year))
                                       years))
         (death-anniversaries (seq-map (lambda (year)
                                         (my/calendar-chinese-anniversary death year))
                                       years))
         (birth-anniversaries (seq-filter (lambda (plist)
                                            (>= (plist-get plist :order) 0))
                                          birth-anniversaries))
         (death-anniversaries (seq-filter (lambda (plist)
                                            (>= (plist-get plist :order) 0))
                                          death-anniversaries))
         (birth-anniversaries (seq-map (lambda (plist)
                                         (let* ((date (plist-get plist :anniversary-gregorian))
                                                (anniversary-abs (calendar-absolute-from-gregorian date))
                                                (order (plist-get plist :order))
                                                (description (cond
                                                              ((> anniversary-abs death-abs)
                                                               (format "%s %d歲農曆生忌" name order))
                                                              ((eql order 0)
                                                               (format "%s 農曆出世" name))
                                                              (t
                                                               (format "%s %d歲農曆生日" name order)))))
                                           (list date description)))
                                       birth-anniversaries))
         (death-anniversaries (seq-map (lambda (plist)
                                         (let* ((date (plist-get plist :anniversary-gregorian))
                                                (order (plist-get plist :order))
                                                (description (if (eql order 0)
                                                                 (format "%s 農曆逝世" name)
                                                               (format "%s 第%d個農曆死忌" name order))))
                                           (list date description)))
                                       death-anniversaries)))
    (holiday-filter-visible-calendar
     (my/holiday-sort (append
                       birth-anniversaries
                       death-anniversaries
                       ;; The date of death is counted as the first day.
                       (holiday-after ref (1- (* 7 1)) (format "%s 頭七" name))
                       (holiday-after ref (1- (* 7 2)) (format "%s 二七" name))
                       (holiday-after ref (1- (* 7 3)) (format "%s 三七" name))
                       (holiday-after ref (1- (* 7 4)) (format "%s 四七" name))
                       (holiday-after ref (1- (* 7 5)) (format "%s 五七" name))
                       (holiday-after ref (1- (* 7 6)) (format "%s 六七" name))
                       (holiday-after ref (1- (* 7 7)) (format "%s 尾七" name))
                       (holiday-after ref (1- 100) (format "%s 百日" name))
                       nil)))))

;;;###autoload
(cl-defun my/holiday-chinese-birth-and-death (name &key birth death)
  "Compute various anniversaries according to BIRTH and DEATH for NAME.

BIRTH must be a non-nil Gregorian date.

DEATH can be nil.
If it is non-nil, then it must be a Gregorian date.

When DEATH is nil, compute 農曆生日。
Otherwise, in addition to 農曆生日, also compute 農曆生忌, 農曆死忌, 七, 及百日.

If BIRTH or DEATH is on a day in a leap month,
then the same day in the previous month is the anniversary.

If BIRTH or DEATH is on 三十,
then it will be taken to be 廿九 in months lacking 三十."
  (if death
      (my/holiday-chinese--birth-and-death name birth death)
    (my/holiday-chinese--birth name birth)))

;;;###autoload
(defun my/holiday-birthdate (name birth death)
  "Return birthdays for NAME and Gregorian date BIRTH.

DEATH can be nil, t, or a Gregorian date."
  (let* ((years (my/holiday-get-years))
         (birth-anniversaries (seq-map (lambda (year)
                                         (my/calendar-anniversary birth year))
                                       years))
         (birth-anniversaries (seq-filter (lambda (plist)
                                            (>= (plist-get plist :order) 0))
                                          birth-anniversaries))
         (birthdays (seq-map (lambda (plist)
                               (let* ((order (plist-get plist :order))
                                      (date (plist-get plist :anniversary))
                                      (description (cond
                                                    ((consp death)
                                                     (if (my/calendar-date> date death)
                                                         (format "%s %d歲生忌" name order)
                                                       (if (eql order 0)
                                                           (format "%s 出世" name)
                                                         (format "%s %d歲生日" name order))))
                                                    ((eql order 0)
                                                     (format "%s 出世" name))
                                                    (death
                                                     (format "%s %d歲生忌" name order))
                                                    (t
                                                     (format "%s %d歲生日" name order)))))
                                 (list date description)))
                             birth-anniversaries)))
    (holiday-filter-visible-calendar birthdays)))

;;;###autoload
(defun my/holiday-birthday (name birth-month birth-day death)
  "Return birthdays for NAME with BIRTH-MONTH and BIRTH-DAY.

DEATH can either be nil, t, or a Gregorian date."
  (let* ((years (my/holiday-get-years))
         (birth-anniversaries (seq-map (lambda (year)
                                         (my/calendar-anniversary (list birth-month birth-day nil) year))
                                       years))
         (birthdays (seq-map (lambda (plist)
                               (let* ((date (plist-get plist :anniversary))
                                      (description (cond
                                                    ((consp death)
                                                     (if (my/calendar-date> date death)
                                                         (format "%s 生忌" name)
                                                       (format "%s 生日" name)))
                                                    (death
                                                     (format "%s 生忌" name))
                                                    (t
                                                     (format "%s 生日" name)))))
                                 (list date description)))
                             birth-anniversaries)))
    (holiday-filter-visible-calendar birthdays)))

;;;###autoload
(defun my/holiday-deathday (name death-month death-day)
  "Return anniversaries of NAME with DEATH-MONTH and DEATH-DAY."
  (let* ((years (my/holiday-get-years))
         (death-anniversaries (seq-map (lambda (year)
                                         (my/calendar-anniversary (list death-month death-day nil) year))
                                       years))
         (output (seq-map (lambda (plist)
                            (let* ((date (plist-get plist :anniversary))
                                   (description (format "%s 死忌" name)))
                              (list date description)))
                          death-anniversaries)))
    (holiday-filter-visible-calendar output)))

;;;###autoload
(defun my/holiday-deathdate (name death)
  "Return anniversaries of NAME and Gregorian date DEATH."
  (let* ((years (my/holiday-get-years))
         (death-anniversaries (seq-map (lambda (year)
                                         (my/calendar-anniversary death year))
                                       years))
         (death-anniversaries (seq-filter (lambda (plist)
                                            (>= (plist-get plist :order) 0))
                                          death-anniversaries))
         (output (seq-map (lambda (plist)
                            (let* ((order (plist-get plist :order))
                                   (date (plist-get plist :anniversary))
                                   (description (cond
                                                 ((eql order 0)
                                                  (format "%s 逝世" name))
                                                 (t
                                                  (format "%s 第%d個死忌" name order)))))
                              (list date description)))
                          death-anniversaries)))
    (holiday-filter-visible-calendar output)))

;;;###autoload
(defun my/holiday-birth-and-death (name birth death)
  "Compute various anniversaries according to BIRTH and DEATH for NAME.

If both BIRTH and DEATH are nil, return nil.
The year component in BIRTH and DEATH can be nil."
  (pcase (list birth death)
    (`((,birth-month ,birth-day nil) nil)
     (my/holiday-birthday name birth-month birth-day nil))
    (`((,birth-month ,birth-day ,birth-year) nil)
     (my/holiday-birthdate name birth nil))
    (`(nil (,death-month ,death-day nil))
     (my/holiday-deathday name death-month death-day))
    (`(nil (,death-month ,death-day ,death-year))
     (my/holiday-deathdate name death))
    (`((,birth-month ,birth-day nil) (,death-month ,death-day nil))
     (my/holiday-sort (append
                       (my/holiday-birthday name birth-month birth-day t)
                       (my/holiday-deathday name death-month death-day)
                       nil)))
    (`((,birth-month ,birth-day ,birth-year) (,death-month ,death-day nil))
     (my/holiday-birthdate name birth t))
    (`((,birth-month ,birth-day nil) (,death-month ,death-day ,death-year))
     (my/holiday-sort (append
                       (my/holiday-birthday name birth-month birth-day death)
                       (my/holiday-deathdate name death)
                       nil)))
    (`((,birth-month ,birth-day ,birth-year) (,death-month ,death-day ,death-year))
     (my/holiday-sort (append
                       (my/holiday-birthdate name birth death)
                       (my/holiday-deathdate name death)
                       (my/holiday-chinese-birth-and-death name :birth birth :death death)
                       nil)))
    (_
     nil)))

;;;###autoload
(defun my/holiday-nyse-observed (month day year)
  "Shift the holiday on YEAR MONTH DAY to either Friday or Monday.

If the date is on Saturday, shift to the previous day, Friday.
If the date is on Sunday, shift to the next day, Monday.

One exception is that if the shifted holiday is in a different year,
then nil is returned."
  (let* ((date (list month day year))
         (abs (calendar-absolute-from-gregorian date))
         (shifted (pcase (calendar-day-of-week date)
                    (6 (calendar-gregorian-from-absolute (1- abs)))
                    (0 (calendar-gregorian-from-absolute (1+ abs)))
                    (_ date))))
    (and (eql year (calendar-extract-year shifted)) shifted)))

(defconst my/holiday-nyse-holidays
  '((holiday-sexp '(my/holiday-nyse-observed 1 1 year) "New Year's Day")
    (holiday-float 1 1 3 "Martin Luther King Jr. Day")
    (holiday-float 2 1 3 "Washington's Birthday")
    (my/holiday-easter -2 "Good Friday")
    (holiday-float 5 1 -1 "Memorial Day")
    (holiday-sexp '(when (>= year 2022) (my/holiday-nyse-observed 6 19 year))
                  "Juneteenth National Independence Day")
    (holiday-sexp '(my/holiday-nyse-observed 7 4 year) "Independence Day")
    (holiday-float 9 1 1 "Labor Day")
    (holiday-float 11 4 4 "Thanksgiving Day")
    (holiday-sexp '(my/holiday-nyse-observed 12 25 year) "Christmas Day"))
  "The list of holidays in NYSE.

Translated from https://nyseguide.srorules.com/rules/52dd09f87d461000b2ad005056883b3a08
with version September 30, 2021 (NYSE-2021-56).")

(provide 'my-holidays)
;;; my-holidays.el ends here
