;;; init-goto-address-mode.el --- init-goto-address-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-hook 'prog-mode-hook #'goto-address-prog-mode)
(add-hook 'text-mode-hook #'goto-address-mode)
(add-hook 'conf-mode-hook #'goto-address-mode)

(provide 'init-goto-address-mode)
;;; init-goto-address-mode.el ends here
