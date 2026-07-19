;;; init-auto-revert-mode.el --- init-auto-revert-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Do not poll on systems that support notification.
 auto-revert-avoid-polling t
 auto-revert-check-vc-info t
 ;; Make it work for Dired buffers.
 global-auto-revert-non-file-buffers t)

(global-auto-revert-mode 1)

(provide 'init-auto-revert-mode)
;;; init-auto-revert-mode.el ends here
