;;; init-hideshow.el --- init-hideshow.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Bind TAB in `hs-minor-mode-map'.
 hs-cycle-filter t
 ;; Show number lines hidden.
 hs-display-lines-hidden t
 ;; Open hidden code blocks and comment blocks when doing isearch.
 hs-isearch-open t
 ;; Remember hidden nested blocks.
 hs-allow-nesting t)

;; Enable `hs-minor-mode' in files with a lot of data.
(add-hook 'nxml-mode-hook #'hs-minor-mode)
(add-hook 'json-ts-mode-hook #'hs-minor-mode)
(add-hook 'toml-ts-mode-hook #'hs-minor-mode)
(add-hook 'yaml-ts-mode-hook #'hs-minor-mode)

(provide 'init-hideshow)
;;; init-hideshow.el ends here
