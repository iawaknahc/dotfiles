(setq inhibit-startup-screen t)
(set-frame-font "JetBrainsMonoNL Nerd Font Mono 13")
(menu-bar-mode -1)

(when (display-graphic-p)
  (tool-bar-mode -1))

;; Echo the incomplete commands after 10ms
(setq echo-keystrokes 0.01)

;; Make C-x = show Unicode character name.
(setq what-cursor-show-names t)

(global-display-line-numbers-mode t)
(setq-default display-line-numbers-width 4)

(setq mac-command-modifier 'meta)
(setq mac-right-command-modifier 'none)

(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha)
(catppuccin-reload)

(use-package mu4e
  :ensure nil
  :config
  (setq mu4e-get-mail-command "mbsync --all")
  (setq mu4e-context-policy 'pick-first)
  (setq mu4e-compose-context-policy 'ask-if-none)
  (setq mu4e-view-scroll-to-next nil)
  ;; 2006-01-02
  (setq mu4e-headers-date-format "%F")
  (setq mu4e-headers-time-format "%T")
  ;; Update every 5 minutes.
  (setq mu4e-update-interval 300)
  ;; Load remote images.
  (setq gnus-blocked-images nil)
  ;; Use the executable `sendmail` in PATH to send emails.
  (setq message-send-mail-function 'message-send-mail-with-sendmail)
  ;; Make the main view use the same window.
  (add-to-list 'display-buffer-alist
               `(,(regexp-quote mu4e-main-buffer-name)
                  display-buffer-same-window))
  (load (expand-file-name "mu4e-contexts.el" user-emacs-directory)))
