;;; init-recentf.el --- init-recentf.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'recentf
  (add-hook 'buffer-list-update-hook #'recentf-track-opened-file))

;; recentf is used by consult-buffer.
(add-hook 'after-init-hook #'recentf-mode)

(provide 'init-recentf)
;;; init-recentf.el ends here
