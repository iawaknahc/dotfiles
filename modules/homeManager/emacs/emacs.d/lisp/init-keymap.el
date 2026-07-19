;;; init-keymap.el --- init-keymap.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Rebind C-x C-b to buffer-menu.
;; This is a recommendation in eintr section 16.7.
(keymap-global-set "<remap> <list-buffers>" #'buffer-menu)

(provide 'init-keymap)
;;; init-keymap.el ends here
