;;; init-rainbow-delimiters.el --- init-rainbow-delimiters.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 rainbow-delimiters
 :ensure nil
 :hook (prog-mode . rainbow-delimiters-mode))

(provide 'init-rainbow-delimiters)
;;; init-rainbow-delimiters.el ends here
