;;; init-flyspell.el --- init-flyspell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'ispell
  (setopt ispell-program-name "hunspell")
  (setopt ispell-dictionary "en_US"))

(defun my/flyspell-turn-on-in-text-mode ()
  "Only turn on `flyspell-mode' when `major-mode' is `text-mode'.

Modes like `toml-ts-mode' derive from `text-mode', but
we certainly do not want `flyspell-mode' to run in those modes."
  (when (eq major-mode 'text-mode)
    (flyspell-mode 1)))

(add-hook 'text-mode-hook #'my/flyspell-turn-on-in-text-mode)
(add-hook 'org-mode-hook #'flyspell-mode)
(add-hook 'markdown-ts-mode-hook #'flyspell-mode)
;; I tried flyspell-prog-mode.
;; But without dictionary, many common terms in programming are considered misspelled.
;; For example, "init", "el".
;; (add-hook 'prog-mode-hook #'flyspell-prog-mode)

(provide 'init-flyspell)
;;; init-flyspell.el ends here
