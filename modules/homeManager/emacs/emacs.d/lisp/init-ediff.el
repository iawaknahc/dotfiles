;;; init-ediff.el --- init-ediff.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; By default, Ediff displays the control buffer in another frame.
 ediff-window-setup-function #'ediff-setup-windows-plain
 ;; Always start Ediff with the A variant on the left, the B variant on the right.
 ediff-merge-split-window-function #'split-window-horizontally
 ediff-split-window-function #'split-window-horizontally)

(provide 'init-ediff)
;;; init-ediff.el ends here
