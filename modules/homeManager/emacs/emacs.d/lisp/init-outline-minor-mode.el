;;; init-outline-minor-mode.el --- init-outline-minor-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

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
(add-hook 'beancount-mode-hook #'outline-minor-mode)

(provide 'init-outline-minor-mode)
;;; init-outline-minor-mode.el ends here
