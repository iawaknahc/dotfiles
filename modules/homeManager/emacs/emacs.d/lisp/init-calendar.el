;;; init-calendar.el --- init-calendar.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setopt
 ;; ISO calendar starts on Monday.
 calendar-week-start-day 1

 ;; Display ISO week number.
 calendar-left-margin 8
 calendar-intermonth-spacing 8
 calendar-intermonth-text
 '(propertize
   (format "W%.2d"
           (nth 0 (calendar-iso-from-absolute (calendar-absolute-from-gregorian (list month day year)))))
   'font-lock-face 'calendar-month-header)

 ;; Display ISO week day number instead of two-letter abbreviation of day name.
 calendar-day-header-array [" 7" " 1" " 2" " 3" " 4" " 5" " 6"]

 ;; Display numeric month.
 calendar-month-header
 '(propertize
   (format "%d-%.2d" year month)
   'font-lock-face 'calendar-month-header)

 ;; Roughly the center of Hong Kong at zoom level 11.
 ;; These two variables are used by `calendar-sunrise-sunset', `sunrise-sunset', and `osm-home'.
 ;; According to the manual, the number of decimal places should be 1.
 calendar-latitude 22.3
 calendar-longitude 114.1
 calendar-location-name "Hong Kong"

 ;; Display date in Org style.
 calendar-date-display-form
 '((format "%s-%.2d-%.2d"
           year
           (string-to-number month)
           (string-to-number day))
   (if dayname (concat " " (substring dayname 0 3))))

 ;; Display time in European style.
 calendar-time-display-form
 '(24-hours ":" minutes
            (if time-zone " (") time-zone (if time-zone ")")))

;; Adopted from https://www.gnu.org/software/emacs/manual/html_node/emacs/Calendar-Customizing.html
;; This marks today with face `calendar-today', which is underline.
(add-hook 'calendar-today-visible-hook #'calendar-mark-today)
;; Mark holidays when calendar is opened.
(add-hook 'calendar-initial-window-hook #'calendar-mark-holidays)

(defun my/holiday-other-holidays-add ()
  "Add my holidays to `holiday-other-holidays'."
  (require 'my-calendar)

  ;; I do not know these calendars.
  (setopt holiday-hebrew-holidays nil)
  (setopt holiday-islamic-holidays nil)
  (setopt holiday-bahai-holidays nil)

  ;; They are replaced by my/holiday-other-holidays-chinese-festivals.
  (setopt holiday-oriental-holidays nil)
  ;; They are replaced by my/holiday-other-holidays-solar-term.
  (setopt holiday-solar-holidays nil)

  (setopt holiday-other-holidays (append my/holiday-other-holidays-solar-term my/holiday-other-holidays-chinese-festivals)))

(add-hook 'after-init-hook #'my/holiday-other-holidays-add)

(provide 'init-calendar)
;;; init-calendar.el ends here
