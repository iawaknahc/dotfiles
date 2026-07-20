;;; init-diff-hl.el --- init-diff-hl.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq diff-hl-flydiff-delay 0.1)

(add-hook 'after-init-hook #'global-diff-hl-mode)
(add-hook 'after-init-hook #'diff-hl-flydiff-mode)
;; Use margin instead of fringe
(add-hook 'after-init-hook #'diff-hl-margin-mode)

(provide 'init-diff-hl)
;;; init-diff-hl.el ends here
