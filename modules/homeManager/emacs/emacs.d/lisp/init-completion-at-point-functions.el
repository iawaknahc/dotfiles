;;; init-completion-at-point-functions.el --- init-completion-at-point-functions.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/get-filepath-before-point ()
  "Looking before point and see if there is a filepath.
Return the filepath if found, otherwise nil."
  (let (result
        (end (point))
        (bol (pos-bol))
        (regexp (rx (or (seq
                         (in "`\"'")
                         (group-n 1
                           (| "/" "~/" "./" "../")
                           (* (in "- !#$%&()*+,./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~")))
                         (in "`\"'"))
                        (seq
                         (| line-start space)
                         (group-n 1
                           (| "/" "~/" "./" "../")
                           (* (in  "-!#$%&()*+,./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~"))))))))
    (save-excursion
      (goto-char bol)
      (while (re-search-forward regexp end t)
        (when (= (match-end 0) end)
          (setq result (buffer-substring-no-properties (match-beginning 1) (match-end 1)))))
      result)))

(defun my/expand-filepath-before-point ()
  "Expand the filepath before point to an absolute path.
The filepath may or may not exist."
  (let* ((filepath (my/get-filepath-before-point))
         (base-directory (or (and buffer-file-name (file-name-directory buffer-file-name)) default-directory)))
    (when filepath
      (expand-file-name filepath base-directory))))

(defun my/resolve-directory-before-point ()
  "Resolve the filepath representing a directory before point.
Return /homeless-shelter if no directory is found."
  (let* ((filepath (my/expand-filepath-before-point)))
    (or (and filepath (file-directory-p filepath) filepath)
        (and filepath (file-directory-p (file-name-directory filepath)) (file-name-directory filepath))
        "/homeless-shelter")))

(defun my/cape-after-change-major-mode-hook ()
  "Add `cape-dabbrev' to `completion-at-point-functions'.

It should be compatible with the existing capf, in terms of beginning position.
`cape-wrap-super' can only merge capf that have the same beginning position.

See https://github.com/minad/cape/blob/2.7/cape.el#L941"
  ;; It is important to check the major mode, otherwise all minibuffers will have `completion-at-point-functions' set, and
  ;; Corfu will interfere with Vertico.
  (when (derived-mode-p '(conf-mode prog-mode text-mode))
    ;; add-hook takes care of making completion-at-point-functions a buffer-local variable, and add t at the end.
    (add-hook 'completion-at-point-functions #'cape-dabbrev nil t)
    ;; Then we merge whatever appears in completion-at-point-functions except the last element (which is t).
    (let* ((without-t (remove t completion-at-point-functions))
           (merged (apply #'cape-capf-super without-t))
           ;; It is important that this CAPF has a prefix-length larger than cape-file.
           ;; Otherwise, this CAPF will be triggered in the following case.
           ;;
           ;; Suppose you type `.`, since `.` is a wildcard character recognized by Orderless,
           ;; this CAPF will be chosen.
           ;; cape-file will not be chosen because `.` is not one of the trigger prefixes.
           ;; By the time you type `/` to make it `./`, it is too late.
           (prefix-length-enforced (cape-capf-prefix-length merged 3)))
      (setq-local
       completion-at-point-functions
       (list
        ;; `org-mode' derives from `text-mode' and it uses pcomplete to do completion.
        ;; Therefore, we have to add the bridge `pcomplete-completions-at-point'.
        ;; We place it at the front of the list with the assumption that
        ;; there is no major modes other than `org-mode' using pcomplete.
        #'pcomplete-completions-at-point
        ;; Trigger prefix is @
        (cape-capf-trigger #'tempel-complete ?@)
        ;; Trigger prefix is `cape-file-prefix'.
        #'cape-file
        prefix-length-enforced
        t)))))

(setq
 cape-file-directory #'my/resolve-directory-before-point
 cape-file-prefix '("/" "~/" "./" "../"))

(add-hook 'after-change-major-mode-hook #'my/cape-after-change-major-mode-hook)

(provide 'init-completion-at-point-functions)
;;; init-completion-at-point-functions.el ends here
