;;; init-grep-mode.el --- init-grep-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; To search in a project, just use `my/project-find-regexp' (C-x p g).
;; Unlike `project-find-regexp', it does not accept prefix argument.
;; Instead, it always prompts for the regexp to search, the base directory, and
;; a list of filename patterns.
;; The base directory is the project root by default.
;; The list of filename patterns can just be empty.
;; A filename pattern is either an entry in `grep-files-aliases',
;; or a space-separated string which will be split by `split-string' before passing
;; to `wildcard-to-regexp'.
;; Note that the result is shown in a XREF buffer, not a `grep-mode' buffer.
;;
;; Compared to `project-find-regexp', `my/project-find-regexp' offers:
;; 1. Refining the search with `repeat-complex-command' (C-x M-:).
;;    It is because `my/project-find-regexp' records the three prompts in three arguments.
;; 2. A unified interface, no more different behavior based on prefix argument.
;; 3. An integration with `multi-file-replace-regexp-as-diff', via
;;    `my/project-find-regexp-replace', which see.
;;
;; To do search-and-replace, do the search with `my/project-find-regexp' first.
;; In the *xref* buffer, M-x `my/project-find-regexp-replace'.
;; It will prompt for a replacement.
;; The replacement is an ordinary Emacs regexp replacement,
;; so back references like \1 are allowed.
;; The command uses `multi-file-replace-regexp-as-diff' behind the scenes,
;; so a diff buffer is produced.
;; If the changes are good, M-x `diff-apply-buffer' to apply the diff.
;; If all hunks apply cleanly, the changed buffers will be saved automatically.
;;
;;; Code:

(require 'grep)
(require 'project)

(declare-function my/xref-multi-file-replace-regexp-as-diff "my-xref")

;; Do not ask to save buffers before search.
(setq grep-save-buffers nil)
;; Suppress appending /dev/null to `grep-command'.
(setq grep-use-null-device nil)
;; This corresponds to --null in `grep-command'.
(setq grep-use-null-filename-separator t)
;; This corresponds to --color=ansi in `grep-command'.
(setq grep-highlight-matches 'always)
;; Always quote for POSIX shell.
;; This is eventually passed as the optional argument to `shell-quote-argument'.
(setq grep-quoting-style t)
;; Ripgrep uses --type, so the default aliases are not applicable.
;; Reset them to nil.
(setq grep-files-aliases nil)
;; Ripgrep respects VC ignore file by default.
(setq grep-find-ignored-directories nil)
;; This variable is unsupported for now.
(setq grep-find-ignored-files nil)

;; Also set `grep-program' to match `grep-command'.
;; `grep-program' is not actually used because `grep-command' is set.
(setq grep-program "rg")

;; `grep-template' is used by `lgrep'.
;; <C> is not included because we have inlined the options.
;;
;; <X> corresponds to `grep-find-ignored-files'.
;; It is not included because `grep-find-ignored-files' is unsupported.
;;
;; <N> is not included because `grep-use-null-device' is nil.
;; <R> is the answer of the first interactive prompt, which is the search pattern.
;;
;; <F> is the answer of the second interactive prompt, which are the type filters and paths.
;; `grep-read-files' is called with the first answer to derive the value.
(setq grep-template "rg --color=ansi --no-heading --with-filename --line-number --null --regexp <R> <F>")

;; `grep-command' is used by `grep'.
(setq grep-command "rg --color=ansi --no-heading --with-filename --line-number --null --regexp ")

(defun my/project--all-directories (root files)
  "Return the directories of FILES and their parents up to ROOT.

All paths returned are expanded."
  (let* ((root (file-name-as-directory (expand-file-name root)))
         (seen (make-hash-table :test #'equal))
         (dirs nil))
    (dolist (file files)
      (let* ((directory (file-name-directory (expand-file-name file))))
        (while (and directory (string-prefix-p root directory) (not (gethash directory seen)))
          (puthash directory t seen)
          (push directory dirs)
          (setq directory (file-name-directory (directory-file-name directory))))))
    (nreverse dirs)))

(defvar-local my/project-find-regexp-regexp nil
  "The regexp used in `my/project-find-regexp'.")

;;;###autoload
(defun my/project-find-regexp (regexp &optional directory filename-patterns)
  "An improved version of `project-find-regexp'.

Always prompt for REGEXP, DIRECTORY, and FILENAME-PATTERNS.
When called non-interactively, DIRECTORY is the project root by default,
and FILENAME-PATTERNS is an empty list, which matches all files.

Return nil."
  (interactive
   (let* ((proj (project-current t))
          (regexp (project--read-regexp)))
     (when (string-empty-p regexp)
       (user-error "An empty regexp matches everything, which may not be what you want"))
     (let* ((proj-root (expand-file-name (project-root proj)))
            (all-files (project-files proj))
            (all-directories (my/project--all-directories proj-root all-files))
            (all-directories-relative (seq-map (lambda (directory)
                                                 (file-relative-name directory proj-root))
                                               all-directories))
            (directory (expand-file-name
                        (completing-read
                         ;; PROMPT
                         (format-prompt "Base directory" "./")
                         ;; COLLECTION
                         (completion-table-with-metadata
                          all-directories-relative
                          '((category . project-file)))
                         ;; PREDICATE
                         nil
                         ;; REQUIRE-MATCH
                         t
                         ;; INITIAL-INPUT
                         nil
                         ;; HIST
                         t
                         ;; DEF
                         "./"
                         ;; INHERIT-INPUT-METHOD
                         nil)
                        proj-root))
            (filename-patterns (let* ((aliases (cons '("*" . "*") grep-files-aliases)))
                                 (completing-read-multiple
                                  ;; PROMPT
                                  (format-prompt "Search %s in files matching wildcard" "*" regexp)
                                  ;; TABLE
                                  (completion-table-with-metadata
                                   (mapcar #'car aliases)
                                   `((category . my/grep-files-aliases)
                                     (annotation-function . ,(lambda (candidate)
                                                               (let* ((patterns (cdr (assoc candidate aliases))))
                                                                 (concat " " patterns))))))
                                  ;; PREDICATE
                                  nil
                                  ;; REQUIRE-MATCH
                                  nil
                                  ;; INITIAL-INPUT
                                  nil
                                  ;; HIST
                                  t
                                  ;; DEF
                                  "*"
                                  ;; INHERIT-INPUT-METHOD
                                  nil))))
       (list regexp directory filename-patterns))))
  (let* ((proj (project-current t (or directory default-directory)))
         (proj-root (expand-file-name (project-root proj))))
    (when (string-empty-p regexp)
      (user-error "An empty regexp matches everything, which may not be what you want"))
    (unless directory
      (setq directory proj-root))
    ;; Assume FILENAME-PATTERNS is ("elisp" "*.el" "ts")
    ;; ("elisp" "*.el" "ts") => ("*.el" "*.el" "*.ts *.tsx")
    (let* ((filename-patterns (seq-map (lambda (pattern)
                                         (or (cdr (assoc pattern grep-files-aliases)) pattern))
                                       filename-patterns))
           ;; ("*.el" "*.el" "*.ts *.tsx") => ("*.el" "*.el" "*.ts" "*.tsx")
           (filename-patterns (seq-mapcat #'split-string filename-patterns))
           (files (project-files proj (list directory)))
           (filename-patterns-regexp (mapconcat #'wildcard-to-regexp filename-patterns "\\|"))
           (files (if (string-empty-p filename-patterns-regexp)
                      files
                    (seq-filter (lambda (file)
                                  (string-match-p filename-patterns-regexp (file-name-nondirectory file)))
                                files)))
           (buf (xref-show-xrefs
                 (apply-partially #'project--find-regexp-in-files regexp files)
                 nil)))
      (unless (bufferp buf)
        (error "Expected `xref-show-xrefs' to return a buffer, but got %S" buf))
      (with-current-buffer buf
        (setq my/project-find-regexp-regexp regexp))
      nil)))

;;;###autoload
(defun my/project-find-regexp-replace (to-string)
  "Prompt for TO-STRING and do `multi-file-replace-regexp-as-diff'.

This command is intended to be run in a *xref* buffer produced by
`my/project-find-regexp'."
  (interactive
   (progn
     (unless my/project-find-regexp-regexp
       (user-error "Current buffer is not a *xref* buffer produced by `my/project-find-regexp'"))
     (list (query-replace-read-to my/project-find-regexp-regexp "Replace" t))))
  (my/xref-multi-file-replace-regexp-as-diff my/project-find-regexp-regexp to-string))

(provide 'init-grep-mode)
;;; init-grep-mode.el ends here
