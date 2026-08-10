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
 evil-normal-state-modes '(conf-mode prog-mode text-mode)
 ;; Make insert state just like emacs state.
 evil-disable-insert-state-bindings t
 ;; I used to set `evil-want-C-u-scroll' to t.
 ;; But we are using Emacs, C-u should be `universal-argument'.
 evil-want-C-u-scroll nil
 ;; Since C-u does not scroll,
 ;; C-d should not scroll.
 evil-want-C-d-scroll nil
 ;; We will rebind `evil-jump-forward' below.
 ;; Thus, the default binding can be reset.
 evil-want-C-i-jump nil
 ;; This matches the behavior of Neovim.
 evil-want-Y-yank-to-eol t
 evil-search-wrap nil
 evil-v$-excludes-newline t
 ;; C-x 2 is split-window-below
 evil-split-window-below t
 ;; C-x 3 is split-window-right
 evil-vsplit-window-right t
 ;; Make CTRL-r work.
 evil-undo-system 'undo-redo)

(add-hook
 'after-init-hook
 (lambda ()
   (require 'goto-chg)
   (require 'evil)

   ;; Rebind `evil-jump-forward' to `<control-i>'.
   ;; This only makes sense if the physical control-i and the physical tab are made separate,
   ;; otherwise, it is a no-op because `<tab>' is mapped to `[9]' in `function-key-map'.
   ;; The separation is done in `init-keymap.el'.
   ;; The motivation of this rebinding is to reserve TAB for org-mode `org-cycle'.
   ;; In addition, it is very nice to have `<control-i>' to jump forward, and
   ;; `C-o' to jump backward.
   (keymap-set evil-motion-state-map "<control-i>" #'evil-jump-forward)

   ;; I do not use `evil-scroll-page-down' or `evil-scroll-page-up',
   ;; so replace their bindings to scroll half page.
   (keymap-set evil-motion-state-map "C-f" #'evil-scroll-down)
   (keymap-set evil-motion-state-map "C-b" #'evil-scroll-up)
   ;; We have to bind C-d to `ignore', otherwise, `delete-char' is invoked.
   (keymap-set evil-motion-state-map "C-d" #'ignore)

   ;; Make n and N have deterministic direction.
   (advice-add 'evil-search-next :around #'my/evil-search-next)
   (advice-add 'evil-search-previous :around #'my/evil-search-previous)
   (evil-mode 1)))

(provide 'init-evil)
;;; init-evil.el ends here
