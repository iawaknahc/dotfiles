;;; init-dired.el --- init-dired.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 dired
 :ensure nil
 :bind
 (:map
  dired-mode-map
  ;; For unknown reason, this command is not bound by default.
  ;; Given that c, C, n, N are bound already in dired-mode,
  ;; we bind it to C-c c and C-c C-c
  ("C-c c" . dired-create-empty-file)
  ("C-c C-c" . dired-create-empty-file)))

(provide 'init-dired)
;;; init-dired.el ends here
