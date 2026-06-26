(setq inhibit-startup-screen t)

(menu-bar-mode -1)

(global-display-line-numbers-mode t)
(setq-default display-line-numbers-width 4)

(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha)
(catppuccin-reload)
