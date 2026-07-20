;;; init-consult.el --- init-consult.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; The :items of `consult-source-project-buffer' is replaced by
;; a version to use `project-buffers'.
;;
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

(defun my/consult-source-project-buffer-items-around (f &rest args)
  "The :around of my/consult-source-project-buffer-items.
Dynamically bind `consult-buffer-list-function' to use `project-buffers'.
`apply' F with ARGS as usual."
  (let ((consult-buffer-list-function (lambda () (project-buffers (project-current)))))
    (apply f args)))

(with-eval-after-load 'consult
  (unless (fboundp #'my/consult-source-project-buffer-items)
    (let ((f (plist-get consult-source-project-buffer :items)))
      (defalias 'my/consult-source-project-buffer-items f)
      (advice-add 'my/consult-source-project-buffer-items :around #'my/consult-source-project-buffer-items-around)
      (plist-put consult-source-project-buffer :items #'my/consult-source-project-buffer-items))))

(provide 'init-consult)
;;; init-consult.el ends here
