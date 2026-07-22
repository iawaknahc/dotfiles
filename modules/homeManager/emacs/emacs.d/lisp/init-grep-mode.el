;;; init-grep-mode.el --- init-grep-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; I tried deadgrep.
;; But it is too simple.
;; For example, it does not support specifying multiple file types.
;; See https://github.com/Wilfred/deadgrep/issues/129
;;
;; So I decided to stick with the built-in `grep-mode'.
;; grep(1) does not respect VC ignore files, so we must customize `grep-mode' to use ripgrep.
;; `grep' uses whatever value `default-directory' as the working directory for `grep-command'.
;; Since the common case is to find-in-project, I installed an advice to `grep' to rebind `default-directory' dynamically to `project-root'.
;; So `grep' means find in project.
;;
;; Note that it is different from `project-find-regexp'.
;; `project-find-regexp' does not use `grep-mode', instead, the buffer is xref.
;;
;; A common use case is to refine the search term after an initial search.
;; This is supported by `grep-mode' out of the box.
;; C-u g brings up a minibuffer with the previous command pre-filled.
;;
;; Grug-far.nvim is a Neovim plugin is similar to grep-mode, and it has native support for type filter and paths.
;; To replicate it, we can append the type filter and paths after the regexp.
;; When `grep' is called interactively, the prompt is pre-filled with `grep-command', like this:
;;
;;  rg --color=auto ... --regexp
;;
;; Let's say we want to search "local" in all Lua files rooted at ./a/b,
;; we will type in:
;;  rg --color=auto ... --regexp local --type lua ./a/b
;;
;;; Code:

(setq
 ;; Do not ask to save buffers before search.
 grep-save-buffers nil
 ;; Suppress appending /dev/null to `grep-command'.
 grep-use-null-device nil
 ;; This corresponds to --null in `grep-command'.
 grep-use-null-filename-separator t
 ;; This corresponds to --color=ansi in `grep-command'.
 grep-highlight-matches 'always
 ;; Always quote for POSIX shell.
 ;; This is eventually passed as the optional argument to `shell-quote-argument'.
 grep-quoting-style t
 ;; Ripgrep uses --type, so the default aliases are not applicable.
 ;; Reset them to ni.
 grep-files-aliases nil
 ;; Ripgrep respects VC ignore file by default.
 grep-find-ignored-directories nil
 ;; This variable is unsupported for now.
 grep-find-ignored-files nil

 ;; Also set `grep-program' to match `grep-command'.
 ;; `grep-program' is not actually used because `grep-command' is set.
 grep-program "rg"

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
 grep-template "rg --color=ansi --no-heading --with-filename --line-number --null --regexp <R> <F>"

 ;; `grep-command' is used by `grep'.
 grep-command "rg --color=ansi --no-heading --with-filename --line-number --null --regexp ")

(defun my/grep-override (command-args)
  "An :override advice of `grep'.
COMMAND-ARGS is prompted.

`default-directory' always dynamically bound to `project-root'."
  (interactive
   (progn
     (let* ((proj (or (project-current) (error "Running lgrep without a project is unsupported")))
            (proj-root (project-root proj))
            (command-args (read-shell-command "Run Ripgrep: " grep-command 'grep-history)))
       (list command-args))))
  (let* ((proj (or (project-current) (error "Running grep without a project is unsupported")))
         (proj-root (project-root proj))
         (default-directory (expand-file-name proj-root)))
    (compilation-start command-args #'grep-mode)))
(advice-add 'grep :override #'my/grep-override)

(defun my/lgrep-parse-files (files)
  "Implement the algorithm documented in `my/lgrep-override'.
FILES is parsed and a string is returned."
  (let* ((components (split-string files))
         (transformed (mapconcat
                       (lambda (component)
                         (pcase component
                           ((pred (string-prefix-p "!" _)) (format "--type-not=%s" (substring component 1)))
                           (_ (format "--type=%s" component)))
                         ) components " ")))
    transformed))

(defun my/lgrep-override (regexp &optional files dir confirm)
  "An :override advice of `lgrep'.

REGEXP is prompted and quoted for shell.

FILES is prompted and the resulting string will be split at spaces.
Each component is treated as a Ripgrep type.
If the component is prefixed with !,
then it will be passed as --type-not COMPONENT.
For example, suppose FILES is 'json yaml',
it will be translated to '--type json --type yaml'.
For example, suppose FILES is '!lua',
it will be translated to '--type-not lua'.

DIR is not prompted, and instead is always set to `project-root'.

CONFIRM is ignored.
It is kept solely for maintaining the original function signature."
  (interactive
   (progn
     (let* ((proj (or (project-current) (error "Running lgrep without a project is unsupported")))
            (proj-root (project-root proj))
            (regexp (read-regexp "Enter a Ripgrep regexp to search: " 'grep-tag-default 'grep-regexp-history))
            (files (read-from-minibuffer "[Optional] space-separated list of Ripgrep types (e.g. sh !zsh): ")))
       (list regexp files proj-root nil))))
  (let* ((types (my/lgrep-parse-files files))
         (command (grep-expand-template grep-template regexp types))
         (default-directory (expand-file-name dir)))
    (compilation-start command #'grep-mode)))
(advice-add 'lgrep :override #'my/lgrep-override)

;; Make the grep window always shown at the bottom.
(add-to-list
 'display-buffer-alist
 `(,(rx string-start "*grep*" string-end)
   (display-buffer-reuse-window display-buffer-in-side-window)
   (side . bottom)
   (window-height . 0.33)))

(provide 'init-grep-mode)
;;; init-grep-mode.el ends here
