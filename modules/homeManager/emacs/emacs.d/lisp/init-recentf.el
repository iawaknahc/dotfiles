;;; init-recentf.el --- init-recentf.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'recentf) ; because recentf-track-opened-file is not autoloaded.

;; recentf is used by consult-buffer.
(add-hook 'buffer-list-update-hook #'recentf-track-opened-file)
(recentf-mode 1)

(provide 'init-recentf)
;;; init-recentf.el ends here
