;;; init-dired.el --- init-dired.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar dired-auto-revert-buffer)
(defvar dired-dwim-target)
(defvar dired-hide-details-hide-information-lines)
(defvar dired-hide-details-hide-symlink-targets)
(defvar dired-hide-details-preserved-columns)
(defvar dired-kill-when-opening-new-dired-buffer)
(defvar dired-mode-map)
(defvar dired-omit-extensions)
(defvar dired-omit-files)
(defvar ls-lisp-format-time-list)
(defvar ls-lisp-use-insert-directory-program)
(defvar ls-lisp-use-localized-time-format)
(declare-function dired-create-empty-file "dired-aux")
(declare-function dired-hide-details-mode "dired")
(declare-function dired-omit-mode "dired-x")

(setq
 ;; Use the Elisp implementation of ls.
 ;; Note that it is used both locally and for TRAMP.
 ls-lisp-use-insert-directory-program nil
 ;; If there is a space in the time, `dired-hide-details-mode'
 ;; will consider the time as 2 columns.
 ;; Thus, we use "T" instead of a space.
 ls-lisp-format-time-list '("%Y-%m-%dT%H:%M" "%Y-%m-%dT%H:%M")
 ;; Always use `ls-lisp-format-time-list'.
 ls-lisp-use-localized-time-format t)
(require 'ls-lisp)

(setq
 ;; Specify the switches supported by ls-lisp.
 ;; See https://github.com/emacs-mirror/emacs/blob/emacs-31.1/lisp/ls-lisp.el#L879
 dired-listing-switches "--almost-all --classify --human-readable --group-directories-first"

 ;; Stop Dired from keeping too many buffers.
 dired-kill-when-opening-new-dired-buffer t
 ;; Revert the buffer when the buffer is revisited.
 dired-auto-revert-buffer t
 ;; When open two Dired buffers side by side,
 ;; guess the target to be the another buffer.
 dired-dwim-target t
 dired-hide-details-hide-symlink-targets t
 dired-hide-details-hide-information-lines t
 ;; When -l is given, according to POSIX,
 ;; 7 columns are generated.
 ;; - Column 1 is file mode (permissions).
 ;; - Column 2 is number of links.
 ;; - Column 3 is owner.
 ;; - Column 4 is group.
 ;; - Column 5 is size.
 ;; - Column 6 is time.
 ;;   This column can be customized by `ls-lisp-format-time-list'.
 ;;   If there is a space in the format string, `dired-hide-details-mode'
 ;;   will consider the time as 2 columns.
 ;; - Column 7 is path name.
 dired-hide-details-preserved-columns '(7)
 ;; Never omit files by extensions.
 dired-omit-extensions nil
 ;; Only omit hidden files.
 dired-omit-files (rx (|
                       ;; Hidden files
                       (seq string-start "." (+ not-newline) string-end))))

(with-eval-after-load 'dired
  ;; For unknown reason, this command is not bound by default.
  ;; Given that c, C, n, N are bound already in dired-mode,
  ;; we bind it to C-c C-c
  (keymap-set dired-mode-map "C-c C-c" #'dired-create-empty-file)
  ;; ( is bound to `dired-hide-details-mode', so
  ;; it follows naturally that ) is bound to `dired-omit-mode'.
  (keymap-set dired-mode-map ")" #'dired-omit-mode)
  (add-hook 'dired-mode-hook #'dired-omit-mode)
  (add-hook 'dired-mode-hook #'dired-hide-details-mode))

(defun my/dired ()
  "Open Dired."
  (interactive)
  (tab-new)
  (dired "~")
  (split-window-right)
  (other-window 1)
  (dired (format "~/Volumes/nas_samba/%s" user-login-name)))
(keymap-global-set "C-c d" #'my/dired)

(provide 'init-dired)
;;; init-dired.el ends here
