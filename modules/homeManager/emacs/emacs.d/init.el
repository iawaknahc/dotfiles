(setq inhibit-startup-screen t)

(menu-bar-mode -1)

(global-display-line-numbers-mode t)
(setq-default display-line-numbers-width 4)

(setq evil-want-keybinding nil)
(setq evil-want-integration t)
(require 'evil)
(require 'evil-collection)
(evil-mode 1)
(evil-collection-init)

(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha)
(catppuccin-reload)
