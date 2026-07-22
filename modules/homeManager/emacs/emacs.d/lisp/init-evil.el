;;; init-evil.el --- init-evil.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/evil-search-next (f &rest args)
  "An :around advice of `evil-search-next' to make it always search forward.
Apply F with ARGS."
  (let ((isearch-forward t))
    (apply f args)))

(defun my/evil-search-previous (f &rest args)
  "An :around advice of `evil-search-previous' to make to always search backward.
Apply F with ARGS."
  ;; This is intentionally.
  ;; evil-search-previous negates isearch-forward internally.
  ;; So we always set it to t.
  (let ((isearch-forward t))
    (apply f args)))

;; Set these before (require 'evil) because some variables have to be set before evil-mode is enabled.
(setq
 ;; The default state is emacs state.
 evil-default-state 'emacs
 ;; Never start with insert state.
 evil-insert-state-modes nil
 ;; Never start with motion state.
 evil-motion-state-modes nil
 ;; The default is emacs state already.
 evil-emacs-state-modes nil
 ;; Start in normal state if we are editing source code or text.
 evil-normal-state-modes '(prog-mode text-mode)
 ;; Make insert state just like emacs state.
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

(add-hook
 'after-init-hook
 (lambda ()
   (require 'goto-chg)
   (require 'evil)

   ;; Make n and N have deterministic direction.
   (advice-add 'evil-search-next :around #'my/evil-search-next)
   (advice-add 'evil-search-previous :around #'my/evil-search-previous)
   (evil-mode 1)))

(provide 'init-evil)
;;; init-evil.el ends here
