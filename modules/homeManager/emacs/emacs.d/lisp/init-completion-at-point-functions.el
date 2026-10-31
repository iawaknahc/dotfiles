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
                           (* (in "- !#$%&()*+,./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_abcdefghijklmnopqrstuvwxyz{|}~"))))
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
The filepath may or may not exist.

Return nil if the string before point is not a filepath."
  (when-let* ((non-essential t)
              (filepath (my/get-filepath-before-point))
              (base-directory (or (and buffer-file-name (file-name-directory buffer-file-name))
                                  default-directory)))
    (expand-file-name filepath base-directory)))

(defun my/resolve-directory-before-point ()
  "Return the existing directory containing the filepath before point.

The returned path ends in a slash.
Return /homeless-shelter if there is no such directory."
  (let* ((non-essential t)
         (filepath (my/expand-filepath-before-point))
         (directory (and filepath (file-name-directory filepath))))
    (if (and directory (file-directory-p directory))
        directory
      "/homeless-shelter")))

(defun my/tempel-capf ()
  "`tempel-complete' triggered by @."
  (cape-wrap-trigger #'tempel-complete ?@))

(defun my/org-pcomplete-capf ()
  "`pcomplete-completions-at-point' in `org-mode' only.

Calling it in all major modes makes Emacs lag on every keystroke.

We want to trigger auto completion when the string before point is #+
To do so, we use :company-prefix-length to override `corfu-auto-prefix'."
  (when (derived-mode-p 'org-mode)
    (cape-wrap-properties #'pcomplete-completions-at-point :company-prefix-length t)))

(defun my/rest-capfs ()
  "Wrap the remaining CAPFs in `completion-at-point-functions'.

The remaining CAPFs are symbols that is not `my/capf'.
The remaining CAPFs and `cape-dabbrev' are wrapped with `cape-wrap-super'.

CAPFs like `elisp-completion-at-point' and `eglot-completion-at-point'
return a lot of candidates.
`cape-dabbrev' must be combined with these CAPFs so that it has a chance
to return candidates."
  (let* ((rest-capfs (seq-filter (lambda (capf)
                                   ;; Skip `my/capf'.
                                   (and (not (eq capf #'my/capf))
                                        ;; And skip t, which is added by `add-hook'.
                                        (not (eq capf t))))
                                 completion-at-point-functions))
         (with-dabbrev (append rest-capfs (list #'cape-dabbrev) nil)))
    (apply #'cape-wrap-super with-dabbrev)))

(defun my/capf ()
  "Return the first of these CAPFs that has a candidate at point."
  ;; We want it to trigger when the string before point is "[[id:"
  (cape-wrap-choose (cape-capf-properties #'my/vulpea-insert-capf :company-prefix-length t)
                    #'my/tempel-capf
                    #'cape-file
                    #'my/org-pcomplete-capf
                    #'my/rest-capfs))

(defun my/cape-after-change-major-mode-hook ()
  "Add `my/capf' ahead of the CAPFs of the major mode and minor modes."
  ;; It is important to check the major mode,
  ;; otherwise all minibuffers will have `completion-at-point-functions' set, and
  ;; Corfu will interfere with Vertico.
  (when (derived-mode-p '(conf-mode prog-mode text-mode))
    (add-hook 'completion-at-point-functions #'my/capf -1 t)))

(setq
 cape-file-directory #'my/resolve-directory-before-point
 cape-file-prefix '("/" "~/" "./" "../"))

(add-hook 'after-change-major-mode-hook #'my/cape-after-change-major-mode-hook)

;; A private function used by `dabbrev-capf' `dabbrev--abbrev-at-point' may signal (user-error "No possible abbreviation preceding point").
;; In my experience, this situation MUST happen in a Magit gitcommit buffer when I start typing.
;; See https://github.com/emacs-mirror/emacs/blob/emacs-31.1/lisp/dabbrev.el#L678
(advice-add 'dabbrev-capf :around #'cape-wrap-silent)

(provide 'init-completion-at-point-functions)
;;; init-completion-at-point-functions.el ends here
