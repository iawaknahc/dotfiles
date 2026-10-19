;;; init-display-line-numbers-mode.el --- init-display-line-numbers-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq display-line-numbers-width 4)

(defun my/display-line-numbers-mode-after-change-major-mode-hook ()
  "Enable `display-line-numbers-mode'."
  (when (my/evil-normal-p)
    (display-line-numbers-mode 1)))

;; Only enable display-line-numbers-mode when editing programming language source code and text files.
;; For example, if display-line-numbers-mode is enabled in the mu4e headers view, the column header and the column content will misalign.
(add-hook 'after-change-major-mode-hook #'my/display-line-numbers-mode-after-change-major-mode-hook)

(provide 'init-display-line-numbers-mode)
;;; init-display-line-numbers-mode.el ends here
