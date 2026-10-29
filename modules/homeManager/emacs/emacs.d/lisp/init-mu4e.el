;;; init-mu4e.el --- init-mu4e.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Use `sendmail-program' to send emails.
 ;; `report-emacs-bug' use this function to send emails.
 send-mail-function #'sendmail-send-it
 ;; Use mu4e in `compose-mail' (C-x m).
 mail-user-agent 'mu4e-user-agent
 ;; This configures the command that the menu item Tools -> Read Mail executes.
 read-mail-command #'mu4e

 ;; Teach mu4e to retrieve emails.
 mu4e-get-mail-command "mbsync --all"
 ;; mbsync puts UID in the filename.
 ;; Moving a mail without changing filename may retain a stale UID.
 mu4e-change-filenames-when-moving t
 ;; When trash a mail, just move it to the trash directory without
 ;; setting the T flag.
 ;; This is particular important when mbsync is used.
 ;; See https://github.com/djcb/mu/issues/1136#issuecomment-2543938870
 mu4e-trash-without-flag t
 ;; Gmail represents labels as directories.
 ;; So the same mail can appear in multiple directories.
 ;; Accept that face and show them all.
 mu4e-search-skip-duplicates nil
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

 ;; By default, when `mu4e-search-include-related' is t,
 ;; forwarded messages in another maildir (for example, Sent Mail) appears in Inbox.
 ;; This is very confusing.
 ;; If we really want to see the thread of a particular message,
 ;; we should invoke `mu4e-action-show-thread', which is bound to "a s" in the headers view.
 mu4e-search-include-related nil

 mu4e-view-fields
 `(:from
   :to
   :cc
   :bcc
   :subject
   :mailing-list
   :date
   :flags
   :tags
   :labels
   :message-id
   :maildir
   :path-abbreviated)

 mu4e-bookmarks
 '((:name
    "Unread non-trashed non-junk messages"
    :query "flag:unread AND NOT maildir:/[tT]rash/ AND NOT maildir:/Deleted.Items/ AND NOT maildir:/[jJ]unk/ AND NOT maildir:/[sS]pam/"
    :key ?u
    ;; Make this favorite.
    ;; This will be used in the global modeline.
    ;; See https://www.djcbsoftware.nl/code/mu/mu4e/Modeline.html#Favorite-bookmark-modeline-item
    :favorite t)
   (:name
    "Junk messages"
    :query "maildir:/[jJ]unk/ OR maildir:/[sS]pam/"
    :key ?j)
   (:name
    "Trashed messages"
    :query "maildir:/[tT]rash/ OR maildir:/Deleted.Items/"
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

(defun my/mu4e-quit (&optional quit)
  "`mu4e-quit' with the meaning of prefix argument swapped.

If QUIT is non-nil, quit mu4e.
Otherwise, bury the buffer."
  (interactive "P")
  (mu4e-quit (not quit)))

(with-eval-after-load 'mu4e
  (keymap-set mu4e-view-mode-map "X" #'my/mu4e-view-in-xwidget-action)
  ;; Rebind q to `my/mu4e-quit' so that q without prefix argument
  ;; just bury the buffer, keep the update timer running.
  (keymap-set mu4e-main-mode-map "q" #'my/mu4e-quit)

  (add-to-list
   'mu4e-header-info-custom
   '(:maildir-first-component
     :name "Mailbox"
     :shortname "Mailbox"
     :help "The first path component of :maildir"
     :function (lambda (msg)
                 (let* ((maildir (mu4e-message-field msg :maildir)))
                   (nth 1 (file-name-split maildir))))))

  (add-to-list
   'mu4e-header-info-custom
   '(:datetime-local
     :name "Date"
     :shortname "Date"
     :help "The date of the message in local timezone"
     :function (lambda (msg)
                 (let* ((encoded-time (mu4e-message-field msg :date)))
                   (format-time-string "%F %T" encoded-time)))))

  (add-to-list
   'mu4e-header-info-custom
   '(:path-abbreviated
     :name "Path"
     :shortname "Path"
     :help "Abbreviated path to the message on the filesystem"
     :function (lambda (msg)
                 (let* ((path (mu4e-message-field msg :path)))
                   (abbreviate-file-name path)))))

  (require 'init-mu4e-contexts))

;; Start mu4e in background so that the update timer starts
;; running along with Emacs.
(add-hook 'emacs-startup-hook (lambda () (mu4e t)))

(provide 'init-mu4e)
;;; init-mu4e.el ends here
