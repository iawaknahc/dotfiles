;;; init-diff-hl.el --- init-diff-hl.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 diff-hl
 :config
 (global-diff-hl-mode 1))

(use-package
 diff-hl-flydiff
 :custom
 (diff-hl-flydiff-delay 0.1)
 :config
 (diff-hl-flydiff-mode 1)
 ;; Use margin instead of fringe
 (diff-hl-margin-mode 1))

(provide 'init-diff-hl)
;;; init-diff-hl.el ends here
