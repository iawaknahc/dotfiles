;;; init-rainbow-delimiters.el --- init-rainbow-delimiters.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-hook 'conf-mode-hook #'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'text-mode-hook #'rainbow-delimiters-mode)

(provide 'init-rainbow-delimiters)
;;; init-rainbow-delimiters.el ends here
