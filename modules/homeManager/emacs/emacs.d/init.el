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

(require 'mu4e)
;; Make the main view use the same window.
(add-to-list 'display-buffer-alist
             `(,(regexp-quote mu4e-main-buffer-name)
               display-buffer-same-window))
(setq mu4e-get-mail-command "mbsync --all")
(setq mu4e-context-policy 'pick-first)
(setq mu4e-compose-context-policy 'ask-if-none)
(setq mu4e-view-scroll-to-next nil)
;; FIXME: set mu4e-attachment-dir in Nix
(setq mu4e-attachment-dir "/Users/louischan/Downloads")
;; 2006-01-02
(setq mu4e-headers-date-format "%F")
(setq mu4e-headers-time-format "%T")
;; Update every 5 minutes.
(setq mu4e-update-interval 300)
;; Load remote images.
(setq gnus-blocked-images nil)
(setq mu4e-contexts
      `(,(make-mu4e-context
           :name "personal"
           :vars '((user-full-name . "Louis Chan")
                   (user-mail-address . "louischan0325@gmail.com")
                   (mu4e-sent-folder . "/louischan0325@gmail.com/[Gmail]/Sent Mail")
                   (mu4e-drafts-folder . "/louischan0325@gmail.com/[Gmail]/Drafts")
                   (mu4e-trash-folder . "/louischan0325@gmail.com/[Gmail]/Trash")
                   (mu4e-refile-folder . "/louischan0325@gmail.com/[Gmail]/All Mail")
                   (mu4e-maildir-shortcuts . ((:maildir "/louischan0325@gmail.com/Inbox" :name "Inbox" :key ?i)
                                              (:maildir "/louischan0325@gmail.com/[Gmail]/All Mail" :name "Archive" :key ?a)
                                              (:maildir "/louischan0325@gmail.com/[Gmail]/Sent Mail" :name "Sent" :key ?s)
                                              (:maildir "/louischan0325@gmail.com/[Gmail]/Drafts" :name "Drafts" :key ?d)
                                              (:maildir "/louischan0325@gmail.com/[Gmail]/Trash" :name "Trash" :key ?t)
                                              (:maildir "/louischan0325@gmail.com/[Gmail]/Spam" :name "Junk" :key ?j)))))))
;; Use the executable `sendmail` in PATH to send emails.
(setq message-send-mail-function 'message-send-mail-with-sendmail)
