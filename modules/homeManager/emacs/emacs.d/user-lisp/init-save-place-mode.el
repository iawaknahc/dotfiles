;;; init-save-place-mode.el --- init-save-place-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'saveplace
  (setopt save-place-autosave-interval 60))
(add-hook 'after-init-hook #'save-place-mode)

(provide 'init-save-place-mode)
;;; init-save-place-mode.el ends here
