;;; init-outline-minor-mode.el --- init-outline-minor-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar outline-minor-mode-cycle)
(defvar outline-minor-mode-map)
(declare-function outline-demote "outline")
(declare-function outline-move-subtree-down "outline")
(declare-function outline-move-subtree-up "outline")
(declare-function outline-promote "outline")

;; Bind TAB and <backtab> in `outline-minor-mode-cycle-map'.
(setq outline-minor-mode-cycle t)

;; Muscle memory from org-mode.
(with-eval-after-load 'outline
  (keymap-set outline-minor-mode-map "M-<right>" #'outline-demote)
  (keymap-set outline-minor-mode-map "M-<left>"  #'outline-promote)
  (keymap-set outline-minor-mode-map "M-<down>"  #'outline-move-subtree-down)
  (keymap-set outline-minor-mode-map "M-<up>"    #'outline-move-subtree-up))

;; Enable `outline-minor-mode' in beancount buffers because
;; these buffers typically have many lines.
(add-hook 'beancount-ts-mode-hook #'outline-minor-mode)
;; Enable `outline-minor-mode' in Elisp buffers because
;; most Elisp files contain outlines.
(add-hook 'emacs-lisp-mode-hook #'outline-minor-mode)

(provide 'init-outline-minor-mode)
;;; init-outline-minor-mode.el ends here
