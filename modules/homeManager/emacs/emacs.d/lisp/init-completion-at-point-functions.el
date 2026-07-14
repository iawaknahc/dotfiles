;;; -*- lexical-binding: t -*-

;; Configure elisp-completion-at-point
(defun my/elisp-completion-at-point-annotation-function (candidate)
  "Annotate CANDIDATE assuming that CANDIDATE is a string that can be converted to an Elisp symbol."
  (when-let ((sym (intern-soft candidate)))
    (cond
      ((special-form-p sym) "special-form")
      ((primitive-function-p sym) "primitive")
      ((native-comp-function-p sym) "native-comp")
      ((byte-code-function-p sym) "byte-code")
      ((macrop sym) "macro")
      ((commandp sym) "command")
      ((functionp sym) "function")
      ((facep sym) "face")
      ((custom-variable-p sym) "custom-var")
      ((special-variable-p sym) "dynamic-var")
      ((or (local-variable-p sym) (local-variable-if-set-p sym)) "buffer-var")
      ((boundp sym) "variable")
      (t "unknown"))))

(defun my/elisp-completion-at-point-around (capf)
  "Wrap CAPF :annotation-function"
  (cape-wrap-properties capf :annotation-function #'my/elisp-completion-at-point-annotation-function))

;; Configure completion-at-point-functions
(defun my/get-filepath-before-point ()
  "Looking before point and see if there is a filepath.
  Return the filepath if found, otherwise nil."
  (let ((end (point))
        (bol (pos-bol))
        (regexp (rx (or (seq (in "`\"'")
                             (group-n 1
                                      (or "/" "./" "../" "~/")
                                      (zero-or-more (in "- !\"#$%&'()*+,./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"))))
                        (seq (group-n 1
                                      (or "/" "./" "../" "~/")
                                      (zero-or-more (in  "-!\"#$%&'()*+,./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")))))))
        result)
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
    (if filepath
      (expand-file-name filepath base-directory))))

(defun my/resolve-directory-before-point ()
  "Resolve the filepath representing a directory before point.
  Return /homeless-shelter if no directory is found."
  (let* ((filepath (my/expand-filepath-before-point)))
    (if filepath
      (or (and (file-directory-p filepath) filepath)
          (and (file-directory-p (file-name-directory filepath)) (file-name-directory filepath))
          "/homeless-shelter"))))

(defun my/cape-after-change-major-mode-hook ()
  ;; Add cape-dabbrev to completion-at-point-functions.
  ;; It should be compatible with the existing capf, in terms of beginning position.
  ;; cape-wrap-super can only merge capf that have the same beginning position.
  ;; See https://github.com/minad/cape/blob/2.7/cape.el#L941
  ;;
  ;; add-hook takes care of making completion-at-point-functions a buffer-local variable, and add t at the end.
  (add-hook 'completion-at-point-functions #'cape-dabbrev nil t)
  ;; Then we merge whatever appears in completion-at-point-functions except the last element (which is t).
  (let* ((without-t (remove t completion-at-point-functions))
         (merged (apply #'cape-capf-super without-t)))
    ;; Finally we put cape-file at the front.
    ;; It is okay to do this because cape-file has very specific trigger prefixes.
    (setq-local completion-at-point-functions (list #'cape-file merged t))))

(use-package
 cape
 :hook (after-change-major-mode-hook . my/cape-after-change-major-mode-hook)
 :custom
 (cape-file-directory #'my/resolve-directory-before-point)
 (cape-file-prefix '("/" "~/" "./" "../")))

(use-package
 emacs
 :config
 (advice-add 'elisp-completion-at-point :around #'my/elisp-completion-at-point-around))

(provide 'init-completion-at-point-functions)
