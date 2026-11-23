;;; init-ediff.el --- init-ediff.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar ediff-merge-split-window-function)
(defvar ediff-split-window-function)
(defvar ediff-window-setup-function)
(declare-function ediff-setup-windows-plain "ediff-wind")

;; By default, Ediff displays the control buffer in another frame.
(setq ediff-window-setup-function #'ediff-setup-windows-plain)
;; Always start Ediff with the A variant on the left, the B variant on the right.
(setq ediff-merge-split-window-function #'split-window-horizontally)
(setq ediff-split-window-function #'split-window-horizontally)

(provide 'init-ediff)
;;; init-ediff.el ends here
