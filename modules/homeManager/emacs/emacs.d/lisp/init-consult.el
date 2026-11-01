;;; init-consult.el --- init-consult.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;;; Code:

;; C-x b
(keymap-global-set "<remap> <switch-to-buffer>" #'consult-buffer)
;; C-x 4 b
(keymap-global-set "<remap> <switch-to-buffer-other-window>" #'consult-buffer-other-window)
;; C-x r b
(keymap-global-set "<remap> <bookmark-jump>" #'consult-bookmark)
;; M-y
(keymap-global-set "<remap> <yank-pop>" #'consult-yank-pop)
;; M-g g or M-g M-g
(keymap-global-set "<remap> <goto-line>" #'consult-goto-line)
;; C-x p b
(keymap-global-set "<remap> <project-switch-to-buffer>" #'consult-project-buffer)
;; M-g i
(keymap-global-set "<remap> <imenu>" #'consult-imenu)

(provide 'init-consult)
;;; init-consult.el ends here
