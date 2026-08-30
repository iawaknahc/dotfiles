;;; init-treesitter.el --- init-treesitter.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; FIXME: nix-ts-mode does not add-to-list auto-mode-alist, as nix-mode does.
;; See https://github.com/NixOS/nix-mode/blob/v1.5.0/nix-mode.el#L1054
(add-to-list 'auto-mode-alist `(,(rx ".nix" string-end) . nix-ts-mode))

;; FIXME: nushell-ts-mode does not use autoload to add-to-list auto-mode-alist.
;; See https://github.com/herbertjones/nushell-ts-mode/blob/49915cd99d62b7e743bd8cf9023a5819479d166f/nushell-ts-mode.el#L352
(add-to-list 'auto-mode-alist `(,(rx ".nu" string-end) . nushell-ts-mode))

(add-to-list 'interpreter-mode-alist `(,(rx "node" string-end) . typescript-ts-mode))
(add-to-list 'interpreter-mode-alist `(,(rx "nodejs" string-end) . typescript-ts-mode))

;; FIXME: As of Emacs 31.1, `markdown-ts-mode' does not autoload itself.
(autoload 'markdown-ts-mode "markdown-ts-mode")
;; FIXME: `markdown-ts-mode' does not hook into `treesit-enabled-modes'.
(add-to-list 'auto-mode-alist `(,(rx ".md" string-end) . markdown-ts-mode))

;; Since Emacs 31, setting `treesit-enabled-modes' to t is the suggested way to enable
;; all bundled treesit modes.
;; The documentation of `treesit-enabled-modes' says that it cannot be set with `setq',
;; it has to be set with `setopt'.
(setopt treesit-enabled-modes t)

(setq treesit-font-lock-level 4)

(provide 'init-treesitter)
;;; init-treesitter.el ends here
