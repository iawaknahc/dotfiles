;;; init-auto-revert-mode.el --- init-auto-revert-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; I have a 30k lines beancount file.
 ;; When `auto-revert-check-vc-info' is set to t,
 ;; `vc-refresh-state' takes a lot of CPU time to run.
 auto-revert-check-vc-info nil
 ;; In my testing, even polling is disabled,
 ;; `vc-refresh-state' is still called.
 auto-revert-avoid-polling t
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
(add-hook 'conf-mode-hook #'auto-revert-mode)
(add-hook 'prog-mode-hook #'auto-revert-mode)
(add-hook 'text-mode-hook #'auto-revert-mode)
(add-hook 'dired-mode-hook #'auto-revert-mode)

(provide 'init-auto-revert-mode)
;;; init-auto-revert-mode.el ends here
