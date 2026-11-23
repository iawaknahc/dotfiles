;;; init-denote.el --- init-denote.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar denote-date-prompt-use-org-read-date)
(defvar denote-directory)
(defvar denote-infer-keywords)
(defvar denote-known-keywords)
(defvar denote-prompts)
(defvar denote-title-prompt-current-default)
(declare-function denote--directory-get-files "denote")
(declare-function denote-directory-files "denote")
(declare-function denote-dired-mode "denote")
(declare-function denote-extract-keywords-from-path "denote")
(declare-function denote-file-has-denoted-filename-p "denote")
(declare-function denote-keywords-prompt "denote")
(declare-function denote-rename-file "denote")
(declare-function denote-retrieve-filename-identifier "denote")
(declare-function denote-retrieve-filename-title "denote")
;; typos:ignore-next-line
(declare-function denote-sluggify-title "denote")
(declare-function denote-title-prompt "denote")

;;;; Options
(setq denote-directory (format "/ssh:nas:/data/smb/%s/archive/" user-login-name))
(setq denote-prompts '(date title keywords))
(setq denote-date-prompt-use-org-read-date t)
(setq denote-known-keywords nil)
(setq denote-infer-keywords t)

;;;; Faces
(with-eval-after-load 'denote
  ;; The time is not very important.
  (set-face-attribute 'denote-faces-hour nil :inherit 'denote-faces-time)
  (set-face-attribute 'denote-faces-minute nil :inherit 'denote-faces-time)
  (set-face-attribute 'denote-faces-second nil :inherit 'denote-faces-time)
  (set-face-attribute 'denote-faces-time nil :inherit 'shadow)
  ;; The face `denote-faces-delimiter' has a hard-coded gray color.
  ;; Unset it and make it inherit from the face `shadow'.
  (set-face-attribute 'denote-faces-delimiter nil :foreground 'unspecified :inherit 'shadow))

;;;; Hooks
(add-hook 'dired-mode-hook #'denote-dired-mode)

;;;; Advice
(defvar my/denote--renaming nil
  "Non-nil if `denote-rename-file' is prompting.")

(defvar my/denote--title nil
  "Title of `denote-rename-file'.")

;; FIXME: Denote 4.3.0 adds denote-directory-files-get-function so this advice is no longer needed.
(defun my/denote--directory-get-files ()
  "Return a list of Denote files in the flat directory variable `denote-directory'.

Only one filesystem call `directory-files' is used.
This should be fast even it is TRAMP.
`denote-excluded-files-regexp' is not respected."
  (seq-filter #'denote-file-has-denoted-filename-p
              (directory-files denote-directory t directory-files-no-dot-files-regexp t)))
(advice-add #'denote--directory-get-files :override #'my/denote--directory-get-files)

;; `denote-title-prompt' does not offer completion on existing titles.
;; So we replace it with one that does.
(defun my/denote-title-prompt (&optional initial-title prompt-text)
  "Prompt for a title with completions of existing titles.

INITIAL-TITLE and PROMPT-TEXT are handled like `denote-title-prompt'."
  (let* ((title (completing-read
                 ;; prompt
                 (format-prompt (or prompt-text "New file TITLE") denote-title-prompt-current-default)
                 ;; collection
                 (delete-dups (seq-filter #'identity (seq-map #'denote-retrieve-filename-title (denote-directory-files))))
                 ;; predicate
                 nil
                 ;; require-match
                 nil
                 ;; initial-input
                 (or initial-title denote-title-prompt-current-default)
                 ;; hist
                 'denote-title-history
                 ;; def
                 denote-title-prompt-current-default)))
    (when my/denote--renaming
      (setq my/denote--title title))
    title))
(advice-add 'denote-title-prompt :override #'my/denote-title-prompt)

(defun my/denote-keywords-prompt--filter-args (args)
  "Replace INITIAL-KEYWORDS in ARGS."
  (if-let* ((initial-keywords (nth 1 args))
            (my/denote--renaming)
            (title my/denote--title)
            ;; codespell:ignore-next-line sluggify
            (title (denote-sluggify-title title))
            ;; All files
            (files (denote-directory-files))
            ;; All files sharing the same title
            (files (seq-filter (lambda (file)
                                 (string= (denote-retrieve-filename-title file) title))
                               files))
            ;; All files sharing the same title with the latest one comes first.
            (files (seq-sort (lambda (a b)
                               (string> (or (denote-retrieve-filename-identifier a) "")
                                        (or (denote-retrieve-filename-identifier b) "")))
                             files))
            ;; Take the latest one
            (files (seq-take files 1))
            (keywords-list (seq-map #'denote-extract-keywords-from-path files))
            (keywords (nth 0 keywords-list))
            (comma-separated (string-join keywords ",")))
      (progn
        (setf (nth 1 args) comma-separated)
        args)
    args))
(advice-add #'denote-keywords-prompt :filter-args #'my/denote-keywords-prompt--filter-args)

(defun my/denote-rename-file--around (orig-fun &rest args)
  "Call ORIG-FUN with ARGS.

Bind `my/denote--renaming' to t, and `my/denote--title' to nil."
  (interactive
   (lambda (spec)
     (let ((my/denote--renaming t)
           (my/denote--title nil))
       (advice-eval-interactive-spec spec))))
  (apply orig-fun args))
(advice-add #'denote-rename-file :around #'my/denote-rename-file--around)

;;;; Commands
(defun my/dired-nas ()
  "Open local and NAS side by side."
  (interactive)
  (tab-new)
  (dired "~")
  (split-window-right)
  (other-window 1)
  (dired denote-directory))

;;;; Keymaps
(keymap-global-set "C-c d" #'my/dired-nas)

;;;; Footer
(provide 'init-denote)
;;; init-denote.el ends here
