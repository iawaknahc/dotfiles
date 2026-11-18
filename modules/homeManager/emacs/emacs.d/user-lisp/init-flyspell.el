;;; init-flyspell.el --- init-flyspell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'ispell
  (setopt ispell-program-name "hunspell")
  (setopt ispell-dictionary "en_US"))

(add-hook 'text-mode-hook #'flyspell-mode)
;; I tried flyspell-prog-mode.
;; But without dictionary, many common terms in programming are considered misspelled.
;; For example, "init", "el".
;; (add-hook 'prog-mode-hook #'flyspell-prog-mode)

(provide 'init-flyspell)
;;; init-flyspell.el ends here
