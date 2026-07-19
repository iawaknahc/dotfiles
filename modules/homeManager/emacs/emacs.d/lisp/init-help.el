;;; init-help.el --- init-help.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Use monospace font in C-h C-h.
 help-for-help-use-variable-pitch nil
 ;; Reuse the same help window.
 help-window-keep-selected t
 ;; Always select the help window.
 help-window-select t)

(provide 'init-help)
;;; init-help.el ends here
