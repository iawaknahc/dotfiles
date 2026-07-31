;;; init-keymap.el --- init-keymap.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; We want to be able to bind different commands to tab and CTRL-i.
;; Here are the facts we need to know.
;;
;; Fact 1: C-i === TAB === 9
;; Fact 2: <tab> is a function key.
;; Fact 3: <tab> is mapped in function-key-map to [9] by default.
;; Fact 4: Most packages map their command to TAB.
;; Fact 5: Most packages never map `<tab>'.
;;
;; Conclusion 1: We want the physical tab key to mean C-i, so that most packages are not broken.
;; Conclusion 2: We want C-i to mean <tab>, so that it can be mapped to something else.
;; Conclusion 3: This means we need to swap <tab> and C-i.
;;
;; Step 1: Undo Fact 3.
(keymap-unset function-key-map "<tab>" t)
;; Step 2: Make C-i means <tab>
(keymap-set key-translation-map "C-i" [tab])
;; Step 3: Make <tab> means C-i
(keymap-set key-translation-map "<tab>" [9])

;; Rebind C-x C-b to buffer-menu.
;; This is a recommendation in eintr section 16.7.
(keymap-global-set "<remap> <list-buffers>" #'buffer-menu)

(provide 'init-keymap)
;;; init-keymap.el ends here
