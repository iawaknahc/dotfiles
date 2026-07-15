;;; init-evil.el --- init-evil.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package goto-chg)

(defun my/evil-search-next (f &rest args)
  "An :around advice of evil-search-next to make it always search forward."
  (let ((isearch-forward t))
    (apply f args)))

(defun my/evil-search-previous (f &rest args)
  "An :around advice of evil-search-previous to make to always search backward."
  ;; This is intentionally.
  ;; evil-search-previous negates isearch-forward internally.
  ;; So we always set it to t.
  (let ((isearch-forward t))
    (apply f args)))

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
 ;; Evil has its own opinions on using insert state in some modes, revert them.
 (dolist (mode evil-insert-state-modes)
         (evil-set-initial-state mode 'emacs))
 ;; Evil has its own opinions on using motion state in some modes, revert them.
 (dolist (mode evil-motion-state-modes)
         (evil-set-initial-state mode 'emacs))
 ;; Make n and N have deterministic direction.
 (advice-add 'evil-search-next :around #'my/evil-search-next)
 (advice-add 'evil-search-previous :around #'my/evil-search-previous)
 (evil-mode 1))

(provide 'init-evil)
;;; init-evil.el ends here
