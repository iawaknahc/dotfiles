;;; init-visual-line-mode.el --- init-visual-line-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Turn on `visual-line-mode' by default.
(add-hook 'prog-mode-hook #'visual-line-mode)
(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'conf-mode-hook #'visual-line-mode)

(provide 'init-visual-line-mode)
;;; init-visual-line-mode.el ends here
