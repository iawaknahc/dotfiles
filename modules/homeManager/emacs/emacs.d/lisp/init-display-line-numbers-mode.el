;;; init-display-line-numbers-mode.el --- init-display-line-numbers-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 emacs
 :custom
 (display-line-numbers-width 4)
 ;; Only enable display-line-numbers-mode when editing programming language source code and text files.
 ;; For example, if display-line-numbers-mode is enabled in the mu4e headers view, the column header and the column content will misalign.
 :hook ((prog-mode . display-line-numbers-mode)
        (text-mode . display-line-numbers-mode)))

(provide 'init-display-line-numbers-mode)
;;; init-display-line-numbers-mode.el ends here
