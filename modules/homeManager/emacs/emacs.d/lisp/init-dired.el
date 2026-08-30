;;; init-dired.el --- init-dired.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 insert-directory-program "gls"
 dired-listing-switches "--all --format=long --human-readable --group-directories-first"
 ;; When open two Dired buffers side by side,
 ;; guess the target to be the another buffer.
 dired-dwim-target t
 dired-hide-details-hide-symlink-targets t
 dired-hide-details-hide-information-lines t
 ;; When -l is given, according to POSIX,
 ;; 7 columns are generated.
 ;; Column 1 is file mode (permissions).
 ;; Column 2 is number of links.
 ;; Column 3 is owner.
 ;; Column 4 is group.
 ;; Column 5 is size.
 ;; Column 6 is date and time.
 ;; Column 7 is path name.
 dired-hide-details-preserved-columns '(5 6 7)
 ;; Never omit files by extensions.
 dired-omit-extensions nil
 ;; Only omit hidden files.
 dired-omit-files (rx (|
                       ;; The current directory
                       (seq string-start "." string-end)
                       ;; The parent directory
                       (seq string-start ".." string-end)
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
