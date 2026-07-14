;;; -*- lexical-binding: t -*-

(use-package
 consult
 :ensure nil
 :bind
  ;; C-x b
 (([remap switch-to-buffer] . consult-buffer)
  ;; C-x 4 b
  ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
  ;; C-x 5 b
  ([remap switch-to-buffer-other-frame] . consult-buffer-other-frame)
  ;; C-x t b
  ([remap switch-to-buffer-other-tab] . consult-buffer-other-tab)
  ;; C-x r b
  ([remap bookmark-jump] . consult-bookmark)
  ;; M-y
  ([remap yank-pop] . consult-yank-pop)
  ;; M-g g or M-g M-g
  ([remap goto-line] . consult-goto-line)
  ;; C-x p b
  ([remap project-switch-to-buffer] . consult-project-buffer)))

(use-package
 embark-consult
 :ensure nil)

(provide 'init-consult)
