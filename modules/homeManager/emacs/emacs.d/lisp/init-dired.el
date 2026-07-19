;;; init-dired.el --- init-dired.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; For unknown reason, this command is not bound by default.
;; Given that c, C, n, N are bound already in dired-mode,
;; we bind it to C-c c and C-c C-c
(with-eval-after-load 'dired
  (keymap-set dired-mode-map "C-c c" #'dired-create-empty-file)
  (keymap-set dired-mode-map "C-c C-c" #'dired-create-empty-file))

(provide 'init-dired)
;;; init-dired.el ends here
