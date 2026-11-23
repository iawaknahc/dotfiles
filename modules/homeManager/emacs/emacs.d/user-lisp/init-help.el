;;; init-help.el --- init-help.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar help-for-help-use-variable-pitch)

;; Use monospace font in C-h C-h.
(setq help-for-help-use-variable-pitch nil)
;; Reuse the same help window.
(setq help-window-keep-selected t)
;; Always select the help window.
(setq help-window-select t)

(provide 'init-help)
;;; init-help.el ends here
