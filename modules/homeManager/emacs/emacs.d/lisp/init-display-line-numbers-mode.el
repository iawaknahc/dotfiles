;;; -*- lexical-binding: t -*-

;; Only enable display-line-numbers-mode when editing programming language source code and text files.
;; For example, if display-line-numbers-mode is enabled in the mu4e headers view, the column header and the column content will misalign.
(dolist
 (hook '(prog-mode-hook text-mode-hook markdown-ts-mode-hook))
 (add-hook hook (lambda () (display-line-numbers-mode 1) (setq display-line-numbers-width 4))))

(provide 'init-display-line-numbers-mode)
