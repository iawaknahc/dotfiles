;;; init-recentf.el --- init-recentf.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; recentf is used by consult-buffer.
(use-package
 recentf
 :ensure nil
 :hook ((buffer-list-update-hook . recentf-track-opened-file))
 :config
 (recentf-mode 1))

(provide 'init-recentf)
;;; init-recentf.el ends here
