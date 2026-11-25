;;; init-grep-mode.el --- init-grep-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; To search in a project, just use `my/project-find-regexp' (C-x p g).
;; Unlike `project-find-regexp', it does not accept prefix argument.
;; Instead, it always prompts for the regexp to search, the base directory, and
;; a list of filename patterns.
;; The base directory is the project root by default.
;; The list of filename patterns can just be empty.
;; The list of filename patterns is a space-separated string of patterns
;; accepted by `wildcard-to-regexp'.
;; In addition to patterns like "*.el",
;; the pattern can also be entries in `grep-files-aliases'.
;; Note that the result is shown in a XREF buffer, not a `grep-mode' buffer.
;;
;; Compared to `project-find-regexp', `my/project-find-regexp' offers:
;; 1. Refining the search with `repeat-complex-command' (C-x M-:).
;;    It is because `my/project-find-regexp' records the three prompts in three arguments.
;; 2. A unified interface, no more different behavior based on prefix argument.
;;
;;; Code:

(require 'cl-lib)
(require 'grep)
(require 'project)

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
  "Return the directories of FILES and their parents up to ROOT."
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

;;;###autoload
(defun my/project-find-regexp (regexp &optional directory filename-patterns)
  "An improved version of `project-find-regexp'.

Always prompt for REGEXP, DIRECTORY, and FILENAME-PATTERNS.
When called non-interactively, DIRECTORY is the project root by default,
and FILENAME-PATTERNS is an empty string, which matches all files."
  (interactive
   (let* ((proj (project-current t))
          (regexp (project--read-regexp)))
     (when (string-empty-p regexp)
       (user-error "An empty regexp matches everything, which may not be what you want"))
     (let* ((proj-root (project-root proj))
            (all-files (project-files proj))
            (all-directories (my/project--all-directories proj-root all-files))
            (directory (project--read-file-name
                        ;; PROJECT
                        proj
                        ;; PROMPT
                        "Base directory"
                        ;; ALL-FILES
                        all-directories
                        ;; PREDICATE
                        nil
                        ;; HIST
                        'file-name-history
                        ;; MB-DEFAULT
                        (project--find-default-from proj-root proj)))
            ;; Re-bind `grep-read-files-function' so that
            ;; the extension of the filename of the current buffer is not used
            ;; to build a candidate.
            ;; For example, if it is a .el file, then *.el is suggested.
            ;; I do not want it.
            (grep-read-files-function (cl-constantly ""))
            ;; Re-bind `grep-files-aliases' to have an empty entry at the front,
            ;; so that the default value is an empty pattern.
            (grep-files-aliases (cons '("" . "") grep-files-aliases))
            (filename-patterns (grep-read-files regexp)))
       (list regexp directory filename-patterns))))
  (let* ((proj (project-current t (or directory default-directory)))
         (proj-root (project-root proj)))
    (when (string-empty-p regexp)
      (user-error "An empty regexp matches everything, which may not be what you want"))
    (unless directory
      (setq directory proj-root))
    (unless filename-patterns
      (setq filename-patterns ""))
    (let* ((files (project-files proj (list directory)))
           (filename-patterns-regexp (mapconcat #'wildcard-to-regexp (split-string filename-patterns) "\\|"))
           (files (if (string-empty-p filename-patterns-regexp)
                      files
                    (seq-filter (lambda (file)
                                  (string-match-p filename-patterns-regexp (file-name-nondirectory file)))
                                files))))
      (xref-show-xrefs
       (apply-partially #'project--find-regexp-in-files regexp files)
       nil))))

(provide 'init-grep-mode)
;;; init-grep-mode.el ends here
