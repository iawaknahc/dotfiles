;;; my-calendar.el --- my-calendar.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'calendar)
(require 'holidays)

(defcustom my/calendar-business-day-holidays nil
  "A variable that works like `holiday-other-holidays' but for calculating business days."
  :type 'sexp)

;;;###autoload
(defun my/calendar-date-string (date)
  "Return a string intended to be used in `calendar-mode-line-format' for DATE."
  (let* ((year (calendar-extract-year date))
         (month (calendar-extract-month date))
         (day-of-month (calendar-extract-day date))
         (iso-date (calendar-iso-from-absolute (calendar-absolute-from-gregorian date)))
         (week-number (calendar-extract-month iso-date))
         (day-of-week (pcase (calendar-extract-day iso-date)
                        (0 7)
                        (a a)))
         (day-of-year (calendar-day-number date))
         (days-in-year (if (calendar-leap-year-p year) 366 365))
         (elapsed-percent (* 100 (/ (float day-of-year) (float days-in-year)))))
    ;; It is observed that the string will be formatted again,
    ;; so the percent sign has to be quoted twice.
    (format "(%04d-%02d-%02d W%2d-%1d %3d/%3d %3.0f%%%%)" year month day-of-month week-number day-of-week day-of-year days-in-year elapsed-percent)))

;;;###autoload
(defun my/calendar-gregorian-from-decode-time (date)
  "Convert `decode-time' DATE to Gregorian date.

Day, month, and year are extracted from DATE directly without any processing."
  (let* ((day (nth 3 date))
         (month (nth 4 date))
         (year (nth 5 date)))
    (list month day year)))

;;;###autoload
(defun my/calendar-gregorian-to-decode-time (date)
  "Convert Gregorian date DATE to `decode-time'.

The return value is in UTC and no DTS is in effect."
  (list
   0 0 0
   (calendar-extract-day date) (calendar-extract-month date) (calendar-extract-year date)
   (calendar-day-of-week date) nil 0))

;;;###autoload
(defun my/calendar-gregorian-to-org-string (date)
  "Format Gregorian date DATE to a Org timestamp string."
  (format-time-string "%Y-%m-%d %a" (encode-time (my/calendar-gregorian-to-decode-time date)) "UTC"))

;;;###autoload
(defun my/calendar-gregorian-iso8601-date-string (date)
  "Format Gregorian date DATE to a ISO8601 date string."
  (format-time-string "%Y-%m-%d" (encode-time (my/calendar-gregorian-to-decode-time date)) "UTC"))

;;;###autoload
(defun my/calendar-gregorian-iso8601-week-string (date)
  "Format Gregorian date DATE to a ISO8601 week string."
  (format-time-string "%G-W%V" (encode-time (my/calendar-gregorian-to-decode-time date)) "UTC"))

;;;###autoload
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

;;;###autoload
(defun my/calendar-date< (date1 date2)
  "Return non-nil if DATE1 < DATE2."
  (< (calendar-absolute-from-gregorian date1) (calendar-absolute-from-gregorian date2)))

;;;###autoload
(defun my/calendar-date-within (beg end date)
  "Return non-nil if DATE >= BEG and DATE <= END."
  (cond
   ((calendar-date-equal date beg) t)
   ((calendar-date-equal date end) t)
   ((and (my/calendar-date< date end) (my/calendar-date< beg date)) t)
   (t nil)))

;;;###autoload
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

;;;###autoload
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

;;;###autoload
(cl-defun my/calendar-gregorian-add (date &key (years 0) (months 0) (weeks 0) (days 0))
  "Add YEARS, MONTHS, WEEKS, DAYS, in that order, to Gregorian date DATE.

YEARS, MONTHS, WEEKS, and DAYS must be integers.
They can be negative, positive or zero."
  (let* ((year (calendar-extract-year date))
         (month (calendar-extract-month date))
         (day (calendar-extract-day date)))

    ;; Handle :years and :months
    (setq months (+ months (* 12 years)))
    (setq month (+ (1- month) months))
    (setq year (+ year (floor month 12)))
    (setq month (1+ (mod month 12)))
    ;; Clamp day to ensure date is valid.
    (setq day (min (calendar-last-day-of-month month year) day))
    (setq date (list month day year))

    ;; Handle :weeks and :days
    (setq days (+ days (* 7 weeks)))
    (calendar-gregorian-from-absolute (+ days (calendar-absolute-from-gregorian date)))))

;;;###autoload
(defun my/calendar-gregorian-from-absolute--before (date)
  "`calendar-gregorian-from-absolute' is documented not supporting dates in BC.

This function checks if DATE is in BC, in other words, DATE is less than or equal to 0.
Raise an error if so."
  (when (<= date 0)
    (error "Dates in BC are not supported by calendar-gregorian-from-absolute")))

;;;###autoload
(advice-add #'calendar-gregorian-from-absolute :before #'my/calendar-gregorian-from-absolute--before)

(provide 'my-calendar)
;;; my-calendar.el ends here
