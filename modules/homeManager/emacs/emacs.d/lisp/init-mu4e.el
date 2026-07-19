;;; init-mu4e.el --- init-mu4e.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'mu4e)

(setq
 mu4e-get-mail-command "mbsync --all"
 mu4e-context-policy 'pick-first
 mu4e-compose-context-policy 'ask-if-none
 mu4e-view-scroll-to-next nil
 ;; 2006-01-02
 mu4e-headers-date-format "%F"
 mu4e-headers-time-format "%T"
 ;; Do not move point after mark
 mu4e-headers-advance-after-mark nil
 ;; Update every 5 minutes.
 mu4e-update-interval 300
 ;; Load remote images.
 gnus-blocked-images nil
 ;; Show the Date: header three times, in different forms.
 ;; 1. The original header.
 ;; 2. The original header converted to local timezone.
 ;; 3. The lapsed time in human readable form.
 gnus-article-date-headers '(original local lapsed)
 ;; Use the executable `sendmail` in PATH to send emails.
 message-send-mail-function 'message-send-mail-with-sendmail
 mu4e-headers-fields
 `((:maildir-first-component . 30)
   (:human-date . ,(length "2006-01-02"))
   (:flags . 6)
   (:from . 30)
   (:subject))
 mu4e-bookmarks
 '((:name
    "Unread non-trashed non-junk messages"
    :query "flag:unread AND NOT flag:trashed AND NOT maildir:/junk/ AND NOT maildir:/Junk/ AND NOT maildir:/[sS]pam/"
    :key ?u
    ;; Make this favorite.
    ;; This will be used in the global modeline.
    ;; See https://www.djcbsoftware.nl/code/mu/mu4e/Modeline.html#Favorite-bookmark-modeline-item
    :favorite t)
   (:name
    "Junk messages"
    :query "maildir:/junk/ OR maildir:/Junk/ OR maildir:/[sS]pam/"
    :key ?j)
   (:name
    "Trashed messages"
    :query "flag:trashed"
    :key ?t)))

;; Make the main view use the same window.
(add-to-list
 'display-buffer-alist
 `((regexp-quote mu4e-main-buffer-name)
   display-buffer-same-window))
(add-to-list
 'mu4e-header-info-custom
 '(:maildir-first-component
   .
   (:name
    "The first path component of :maildir"
    :shortname "Mailbox"
    :help "The first path component of :maildir"
    :function (lambda (msg)
                      (let* ((maildir (mu4e-message-field msg :maildir)))
                        (nth 1 (file-name-split maildir)))))))
(require 'init-mu4e-contexts)

(provide 'init-mu4e)
