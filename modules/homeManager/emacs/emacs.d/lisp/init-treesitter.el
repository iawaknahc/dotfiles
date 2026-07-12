;;; -*- lexical-binding: t -*-

(setq treesit-font-lock-level 4)

;; FIXME: Remove this when lua-mode becomes built-in.
(add-to-list 'major-mode-remap-alist '(lua-mode . lua-ts-mode))

(add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode))
(add-to-list 'major-mode-remap-alist '(tsx-mode . tsx-ts-mode))

(use-package
 markdown-ts-mode
 :ensure nil
 :config
 (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode)))

(provide 'init-treesitter)
