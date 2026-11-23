;;; init-hideshow.el --- init-hideshow.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar hs-allow-nesting)
(defvar hs-cycle-filter)
(defvar hs-display-lines-hidden)
(defvar hs-isearch-open)

;; Bind TAB in `hs-minor-mode-map'.
(setq hs-cycle-filter t)
;; Show number lines hidden.
(setq hs-display-lines-hidden t)
;; Open hidden code blocks and comment blocks when doing isearch.
(setq hs-isearch-open t)
;; Remember hidden nested blocks.
(setq hs-allow-nesting t)

;; Enable `hs-minor-mode' in files with a lot of data.
(add-hook 'nxml-mode-hook #'hs-minor-mode)
(add-hook 'json-ts-mode-hook #'hs-minor-mode)
(add-hook 'toml-ts-mode-hook #'hs-minor-mode)
(add-hook 'yaml-ts-mode-hook #'hs-minor-mode)

(provide 'init-hideshow)
;;; init-hideshow.el ends here
