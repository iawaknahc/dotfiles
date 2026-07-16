;;; init-treesitter.el --- init-treesitter.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 treesit
 :ensure nil
 :mode (("\\.nu\\'" . nushell-ts-mode)
        ("\\.fnl\\'" . fennel-mode))
 :custom
 (treesit-font-lock-level 4)
 :config
 ;; FIXME: Remove this when lua-mode becomes built-in.
 (add-to-list 'major-mode-remap-alist '(lua-mode . lua-ts-mode))
 (add-to-list 'major-mode-remap-alist '(typescript-mode . typescript-ts-mode))
 (add-to-list 'major-mode-remap-alist '(tsx-mode . tsx-ts-mode))
 (add-to-list 'major-mode-remap-alist '(nix-mode . nix-ts-mode)))

(provide 'init-treesitter)
;;; init-treesitter.el ends here
