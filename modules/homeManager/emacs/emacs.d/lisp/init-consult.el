;;; init-consult.el --- init-consult.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; C-x b
(keymap-global-set "<remap> <switch-to-buffer>" #'consult-buffer)
;; C-x 4 b
(keymap-global-set "<remap> <switch-to-buffer-other-window>" #'consult-buffer-other-window)
;; C-x 5 b
(keymap-global-set "<remap> <switch-to-buffer-other-frame>" #'consult-buffer-other-frame)
;; C-x t b
(keymap-global-set "<remap> <switch-to-buffer-other-tab>" #'consult-buffer-other-tab)
;; C-x r b
(keymap-global-set "<remap> <bookmark-jump>" #'consult-bookmark)
;; M-y
(keymap-global-set "<remap> <yank-pop>" #'consult-yank-pop)
;; M-g g or M-g M-g
(keymap-global-set "<remap> <goto-line>" #'consult-goto-line)
;; C-x p b
(keymap-global-set "<remap> <project-switch-to-buffer>" #'consult-project-buffer)

(provide 'init-consult)
;;; init-consult.el ends here
