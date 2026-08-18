;;; my-datetime.el --- my-datetime.el -*- lexical-binding: t -*-
;;; Commentary:

;; The package defines a number of alternatives to the built-in functions.
;;
;; `my/current-time' is an alternative to `current-time'.
;; It binds `current-time-list' to nil.
;;
;; `my/decode-time' is an alternative to `decode-time'.
;; It forces the value of FORM to t.
;;
;; `my/decoded-time-second' is an alternative to `decoded-time-second'.
;; It returns nil, an integer, or a float.
;; It never returns (TICKS . HZ).
;;
;; `my/decoded-time-weekday' is an alternative to `decoded-time-weekday'.
;; It returns week of day in ISO8601 convention, where Sunday is 7 and Monday is 1.

;;; Code:

;;;###autoload
(defun my/current-time ()
  "Invoke `current-time' with `current-time-list' bound to nil."
  (let* ((current-time-list nil))
    (current-time)))

;;;###autoload
(defun my/decode-time (&optional time zone)
  "Invoke `decode-time' with FORM being t.

If TIME is nil, it is taken to be the current time, obtained by `my/current-time'.
If ZONE is nil, it is taken to be the value of environment variable TZ."
  (let* ((form t))
    (pcase (list time zone)
      (`(nil nil) (decode-time (my/current-time) (getenv "TZ") form))
      (`(nil ,zone) (decode-time (my/current-time) zone form))
      (`(,time nil) (decode-time time (getenv "TZ") form))
      (`(,time ,zone) (decode-time time zone form)))))

;;;###autoload
(defun my/decoded-time-second (time &optional form)
  "Return SEC of TIME according to FORM.

If SEC of TIME is nil, nil is returned.

If FORM is nil and SEC of TIME is an integer, an integer is returned.
If FORM is nil and SEC of TIME is (TICKS . HZ), a float is returned.
If FORM is `integer', SEC of TIME is truncated and then returned.
If FORM is `float', a float is returned."
  (let* ((result (pcase (decoded-time-second time)
                   (`(,ticks . ,frequency) (/ (float ticks) (float frequency)))
                   (int-or-nil int-or-nil))))
    (when result
      (pcase form
        ('nil result)
        ('integer (truncate result))
        ('float (float result))
        (_ (error "FORM must be nil, integer or float"))))))

;;;###autoload
(defun my/decoded-time-weekday (time)
  "Invoke `decoded-time-weekday' with TIME and return ISO8601 weekday.
That is, Sunday is 7 and Monday is 1."
  (let* ((result (decoded-time-weekday time)))
    (pcase result
      (0 7)
      (_ result))))

(provide 'my-datetime)
;;; my-datetime.el ends here
