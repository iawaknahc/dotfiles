;;; init-diff-hl.el --- init-diff-hl.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq diff-hl-flydiff-delay 0.1)

(add-hook 'after-init-hook #'global-diff-hl-mode)
(add-hook 'after-init-hook #'diff-hl-flydiff-mode)
;; Use margin instead of fringe
(add-hook 'after-init-hook #'diff-hl-margin-mode)

(with-eval-after-load 'magit
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

(defun my/vc-refresh-state-on-focus ()
  "Listen to `after-focus-change-function' and call `vc-refresh-state' and `diff-hl-update'."
  (when (and (frame-focus-state) buffer-file-name (vc-backend buffer-file-name))
    (vc-refresh-state)
    (when (bound-and-true-p diff-hl-mode)
      (diff-hl-update))))
(add-function :after after-focus-change-function #'my/vc-refresh-state-on-focus)

(provide 'init-diff-hl)
;;; init-diff-hl.el ends here
