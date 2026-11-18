;;; init-diff-hl.el --- init-diff-hl.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar diff-hl-flydiff-delay)
(declare-function diff-hl-flydiff-mode "diff-hl-flydiff")
(declare-function diff-hl-magit-post-refresh "diff-hl")
(declare-function diff-hl-margin-mode "diff-hl-margin")
(declare-function diff-hl-update "diff-hl")
(declare-function global-diff-hl-mode "diff-hl")

(setq diff-hl-flydiff-delay 0.1)

(add-hook 'after-init-hook #'global-diff-hl-mode)
(add-hook 'after-init-hook #'diff-hl-flydiff-mode)
;; Use margin instead of fringe
(add-hook 'after-init-hook #'diff-hl-margin-mode)

(with-eval-after-load 'magit
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(defun my/vc-refresh-state-on-focus ()
  "Call `vc-refresh-state' and `diff-hl-update' when the frame gains focus.
This function is meant for `after-focus-change-function'."
  (when (and (frame-focus-state) buffer-file-name (vc-backend buffer-file-name))
    (vc-refresh-state)
    (when (bound-and-true-p diff-hl-mode)
      (diff-hl-update))))
(add-function :after after-focus-change-function #'my/vc-refresh-state-on-focus)

(provide 'init-diff-hl)
;;; init-diff-hl.el ends here
