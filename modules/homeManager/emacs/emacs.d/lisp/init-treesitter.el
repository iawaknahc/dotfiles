;;; -*- lexical-binding: t -*-

(use-package
 treesit
 :ensure nil
 :custom
 (treesit-font-lock-level 4)
 :config
 ;; FIXME: Remove this when lua-mode becomes built-in.
 (add-to-list 'major-mode-remap-alist '(lua-mode . lua-ts-mode))
 (add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode))
 (add-to-list 'major-mode-remap-alist '(tsx-mode . tsx-ts-mode))
 (add-to-list 'major-mode-remap-alist '(nix-mode . nix-ts-mode))
 (add-to-list 'major-mode-remap-alist '(markdown-mode . markdown-ts-mode)))

(provide 'init-treesitter)
