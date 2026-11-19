;;; init-denote.el --- init-denote.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar denote-date-prompt-use-org-read-date)
(defvar denote-directory)
(defvar denote-known-keywords)
(declare-function denote-dired-mode "denote")

(setq
 denote-directory "~/Downloads/"
 denote-date-prompt-use-org-read-date t
 denote-known-keywords nil)
(add-hook 'dired-mode-hook #'denote-dired-mode)

(provide 'init-denote)
;;; init-denote.el ends here
