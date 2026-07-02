(setq inhibit-startup-screen t)
(set-frame-font "JetBrainsMonoNL Nerd Font Mono 13")
(menu-bar-mode -1)

(when (display-graphic-p)
  (tool-bar-mode -1))

(global-display-line-numbers-mode t)
(setq-default display-line-numbers-width 4)

(setq mac-command-modifier 'meta)
(setq mac-right-command-modifier 'none)

(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha)
(catppuccin-reload)
