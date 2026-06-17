(setq inhibit-startup-screen t)

(menu-bar-mode -1)

(global-display-line-numbers-mode t)
(setq-default display-line-numbers-width 4)

(setq evil-want-keybinding nil)
(setq evil-want-integration t)
(setq etcc-use-blink nil)

(require 'evil)
(require 'evil-collection)
(require 'evil-terminal-cursor-changer)

(evil-mode 1)
(evil-collection-init)
(etcc-on)

(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha)
(catppuccin-reload)
