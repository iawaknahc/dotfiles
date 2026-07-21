;;; init-sh-mode.el --- init-sh-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; shfmt uses tab by default.
;; By default, sh-basic-offset is 4 while tab-width is 8.
;; If tab is used for indentation, the two must be equal.
;; Otherwise, when a new line is opened, 4 spaces are inserted.
;; So we set sh-basic-offset to the value of tab-width.
(add-hook
 'sh-base-mode-hook
 (lambda ()
   (setq
    indent-tabs-mode t
    sh-basic-offset tab-width)))

(provide 'init-sh-mode)
;;; init-sh-mode.el ends here
