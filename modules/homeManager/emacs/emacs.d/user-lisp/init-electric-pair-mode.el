;;; init-electric-pair-mode.el --- init-electric-pair-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-hook 'conf-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'text-mode-hook #'electric-pair-local-mode)

(provide 'init-electric-pair-mode)
;;; init-electric-pair-mode.el ends here
