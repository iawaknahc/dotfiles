;;; -*- lexical-binding: t -*-

(use-package
 evil
 :init
 (setq
  evil-default-state 'emacs
  evil-want-Y-yank-to-eol t
  evil-search-wrap nil
  evil-v$-excludes-newline t
  evil-split-window-below t
  evil-vsplit-window-right t)
 :config
 (dolist (mode '(prog-mode text-mode markdown-ts-mode))
         (evil-set-initial-state mode 'normal))
 (evil-mode 1))

(provide 'init-evil)
