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

(defun my/diff-hl-vc-refresh-state-after ()
  "An :after advice of `vc-refresh-state' to invoke `diff-hl-update'.
`vc-refresh-state' is called by Auto-Revert mode when `auto-revert-check-vc-info' is t."
  (diff-hl-update))
(advice-add #'vc-refresh-state :after #'my/diff-hl-vc-refresh-state-after)

(provide 'init-diff-hl)
;;; init-diff-hl.el ends here
