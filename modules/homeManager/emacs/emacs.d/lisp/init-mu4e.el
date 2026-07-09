;;; -*- lexical-binding: t -*-

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
  ;; Do not move point after mark
  (setq mu4e-headers-advance-after-mark nil)
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
  (require 'init-mu4e-contexts))

(provide 'init-mu4e)
