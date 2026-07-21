;;; init-auto-revert-mode.el --- init-auto-revert-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Do not poll on systems that support notification.
 auto-revert-avoid-polling t
 auto-revert-check-vc-info t
 ;; The documentation of `global-auto-revert-non-file-buffers' is for
 ;; Global Auto-Revert Mode to operate on non-file buffers, including
 ;; Dired buffers and Buffer List buffer.
 ;; But it does not mention a caveat.
 ;; The marks I place in the Buffer List buffer is reverted every
 ;; `auto-revert-interval' seconds.
 ;; This is definitely a bug!
 global-auto-revert-non-file-buffers nil)

;; Therefore, instead of turning on `global-auto-revert-mode',
;; we turn on the local `auto-revert-mode' in file-visiting buffers,
;; and Dired buffers.
(add-hook 'prog-mode-hook #'auto-revert-mode)
(add-hook 'text-mode-hook #'auto-revert-mode)
(add-hook 'dired-mode-hook #'auto-revert-mode)

(provide 'init-auto-revert-mode)
;;; init-auto-revert-mode.el ends here
