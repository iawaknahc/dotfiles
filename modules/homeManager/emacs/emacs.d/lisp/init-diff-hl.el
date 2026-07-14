;;; -*- lexical-binding: t -*-

(use-package
 diff-hl
 :config
 (global-diff-hl-mode 1))

(use-package
 diff-hl-flydiff
 :custom
 (diff-hl-flydiff-delay 0.1)
 :config
 (diff-hl-flydiff-mode 1))

(provide 'init-diff-hl)
