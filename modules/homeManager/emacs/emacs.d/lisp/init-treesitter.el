;;; init-treesitter.el --- init-treesitter.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; nix-ts-mode does not add-to-list auto-mode-alist, as nix-mode does.
;; See https://github.com/NixOS/nix-mode/blob/v1.5.0/nix-mode.el#L1054
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-ts-mode))

;; nushell-ts-mode does not use autoload to add-to-list auto-mode-alist.
;; See https://github.com/herbertjones/nushell-ts-mode/blob/49915cd99d62b7e743bd8cf9023a5819479d166f/nushell-ts-mode.el#L352
(add-to-list 'auto-mode-alist '("\\.nu\\'" . nushell-ts-mode))

;; FIXME: Revisit in Emacs 31 when treesit-enabled-modes is available.
;; See https://github.com/emacs-mirror/emacs/blob/emacs-30.2/lisp/progmodes/lua-ts-mode.el#L846
(require 'lua-ts-mode) ; lua-ts-mode is built-in but it is not autoloaded in 30.2.

;; FIXME: Revisit in Emacs 31 when treesit-enabled-modes is available.
;; See https://github.com/emacs-mirror/emacs/blob/emacs-30.2/lisp/progmodes/typescript-ts-mode.el#L546
(require 'typescript-ts-mode) ; typescript-ts-mode is built-in but it is not autoloaded in 30.2.

;; FIXME: Revisit in Emacs 31 when treesit-enabled-modes is available.
;; See https://github.com/emacs-mirror/emacs/blob/emacs-30.2/lisp/progmodes/go-ts-mode.el#L301
(require 'go-ts-mode) ; go-ts-mode is built-in but it is not autoloaded in 30.2.

;; FIXME: Revisit in Emacs 31 when treesit-enabled-modes is available.
;; See https://github.com/emacs-mirror/emacs/blob/emacs-30.2/lisp/progmodes/dockerfile-ts-mode.el#L170
(require 'dockerfile-ts-mode)

(setq treesit-font-lock-level 4)

(provide 'init-treesitter)
;;; init-treesitter.el ends here
