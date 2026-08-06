;;; init-tab-bar.el --- init-tab-bar.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Show tab number.
 tab-bar-tab-hints t
 ;; The default is '(tab-bar-format-history
 ;;                  tab-bar-format-tabs
 ;;                  tab-bar-separator
 ;;                  tab-bar-format-add-tab)
 ;; So it means we want to get rid of the history buttons, and group the tabs.
 tab-bar-format
 '(
   tab-bar-format-tabs-groups
   tab-bar-separator
   tab-bar-format-add-tab))

(tab-bar-mode 1)
;; `tab-bar-history-mode' is `winner-mode'.
(tab-bar-history-mode 1)

(provide 'init-tab-bar)
;;; init-tab-bar.el ends here
