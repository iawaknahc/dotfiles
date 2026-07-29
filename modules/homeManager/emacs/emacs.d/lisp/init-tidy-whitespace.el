;;; init-tidy-whitespace.el --- init-tidy-whitespace.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Fix newline as soon as the file is visited.
 mode-require-final-newline 'visit-save
 ;; Make `delete-trailing-whitespace' delete blank lines at the end of buffer.
 delete-trailing-lines t)

(defun my/add-delete-trailing-whitespace-hook ()
  "Add `delete-trailing-whitespace' to `before-save-hook' and make it local.
Also run `delete-trailing-whitespace' now.
This matches the behavior of `visit-save' of `mode-require-final-newline'."
  (add-hook 'before-save-hook #'delete-trailing-whitespace nil t)
  (delete-trailing-whitespace))

(add-hook 'conf-mode-hook #'my/add-delete-trailing-whitespace-hook)
(add-hook 'prog-mode-hook #'my/add-delete-trailing-whitespace-hook)
(add-hook 'text-mode-hook #'my/add-delete-trailing-whitespace-hook)

(provide 'init-tidy-whitespace)
;;; init-tidy-whitespace.el ends here
