;;; init-mu4e.el --- init-mu4e.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Teach mu4e to retrieve emails.
 mu4e-get-mail-command "mbsync --all"
 ;; Use the executable `sendmail` in PATH to send emails.
 message-send-mail-function 'message-send-mail-with-sendmail
 ;; Use mu4e in `compose-mail' (C-x m).
 mail-user-agent 'mu4e-user-agent
 ;; This configures the command that the menu item Tools -> Read Mail executes.
 read-mail-command #'mu4e
 ;; Do not ask when quitting mu4e.
 mu4e-confirm-quit nil
 ;; Do not echo messages to echo area.
 mu4e-hide-index-messages t
 ;; Update every 5 minutes.
 mu4e-update-interval 300

 ;; Contexts
 mu4e-context-policy 'pick-first
 mu4e-compose-context-policy 'ask-if-none

 ;; Do not move to the next message when scrolled to the end of a message.
 mu4e-view-scroll-to-next nil
 ;; Load remote images.
 gnus-blocked-images nil
 ;; Show the Date: header three times, in different forms.
 ;; 1. The original header.
 ;; 2. The original header converted to local timezone.
 ;; 3. The lapsed time in human readable form.
 gnus-article-date-headers '(original local lapsed)

 ;; 2006-01-02
 mu4e-headers-date-format "%F"
 mu4e-headers-time-format "%T"
 ;; Do not move point after mark
 mu4e-headers-advance-after-mark nil
 mu4e-headers-fields
 `((:maildir-first-component . 30)
   (:datetime-local . ,(length "2006-01-02 03:04:05"))
   (:flags . 6)
   (:from . 30)
   (:subject . nil))
 ;; Show more information in the echo area via Eldoc.
 mu4e-eldoc-support t
 ;; %F is the stringified Lisp form of flags, for example, (seen personal).
 ;; %s is the subject.
 mu4e-headers-eldoc-format "%F %s"

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

(defun my/mu4e-headers-found-hook ()
  "Fix the alignment of the header in the headers view.
This is required because we set `left-margin-width' to 2 globally,
which mu4e does not account for.

Although the documentation says we should add a hook to `mu4e-headers-mode-hook',
`header-line-format' was actually set before `mu4e-headers-found-hook' is run.
See https://github.com/djcb/mu/blob/v1.14.3/mu4e/mu4e.texi#L4996
and https://github.com/djcb/mu/blob/v1.14.3/mu4e/mu4e-headers.el#L888"
  (push '(:eval (make-string left-margin-width ?\s)) header-line-format))
(add-hook 'mu4e-headers-found-hook #'my/mu4e-headers-found-hook)

(defun my/mu4e-view-in-xwidget-action ()
  "Call `mu4e-action-view-in-xwidget' with the message at point.
It is literally a shortcut to `a x`.
But `a` is not implemented as a keymap,
so we need this wrapper."
  (interactive)
  (let ((msg (mu4e-message-at-point)))
    (mu4e-action-view-in-xwidget msg)))

(with-eval-after-load 'mu4e
  (keymap-set mu4e-view-mode-map "X" #'my/mu4e-view-in-xwidget-action)

  (add-to-list
   'mu4e-header-info-custom
   '(:maildir-first-component
     :name "The first path component of :maildir"
     :shortname "Mailbox"
     :help "The first path component of :maildir"
     :function (lambda (msg)
                 (let* ((maildir (mu4e-message-field msg :maildir)))
                   (nth 1 (file-name-split maildir))))))

  (add-to-list
   'mu4e-header-info-custom
   '(:datetime-local
     :name "Datetime local"
     :shortname "Date"
     :help "Datetime without UTC offset because the offset is always local"
     :function (lambda (msg)
                 (let* ((encoded-time (mu4e-message-field msg :date)))
                   (format-time-string "%F %T" encoded-time)))))

  (require 'init-mu4e-contexts))

(provide 'init-mu4e)
;;; init-mu4e.el ends here
