;;; init-timezone.el --- init-timezone.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Set a static timezone.
;; So every Org-mode timestamp is actually referring to this timezone,
;; regardless of where we are.
(setenv "TZ" "Asia/Hong_Kong")

(provide 'init-timezone)
;;; init-timezone.el ends here
