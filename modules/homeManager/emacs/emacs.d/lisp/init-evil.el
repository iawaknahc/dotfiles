;;; init-evil.el --- init-evil.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package goto-chg)

(use-package
 evil
 :after (goto-chg)
 ;; Use :init instead of :custom because some variables have to be set before evil-mode is enabled.
 :init
 (setq
  ;; Emacs by default.
  evil-default-state 'emacs
  ;; Make insert state just like Emacs state.
  evil-disable-insert-state-bindings t
  ;; C-u to scroll half page.
  evil-want-C-u-scroll t
  evil-want-Y-yank-to-eol t
  evil-search-wrap nil
  evil-v$-excludes-newline t
  ;; C-x 2 is split-window-below
  evil-split-window-below t
  ;; C-x 3 is split-window-right
  evil-vsplit-window-right t)
 :config
  ;; Unless we are editing source code or text.
 (evil-set-initial-state 'prog-mode 'normal)
 (evil-set-initial-state 'text-mode 'normal)
 (evil-mode 1))

(provide 'init-evil)
;;; init-evil.el ends here
