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
 ;; This corresponds to --color=auto in `grep-command'.
 grep-highlight-matches 'auto
 ;; Also set `grep-program' to match `grep-command'.
 ;; `grep-program' is not actually used because `grep-command' is set.
 grep-program "rg"
 ;; <C> is not included because we have inlined the options.
 ;; <X> is not included because we do not support it.
 ;; <N> is not included because `grep-use-null-device' is nil.
 ;; <R> is where the search regexp should go.
 ;; <F> is where we put type filter and paths.
 ;; `grep-template' is not actually used because `grep-command' is set.
 grep-template "rg --color=auto --no-heading --with-filename --line-number --null --regexp <R> <F>"
 grep-command "rg --color=auto --no-heading --with-filename --line-number --null --regexp ")

(defun my/grep-around (f &rest args)
  (let* ((proj (or (project-current) (error "Running grep without a project is not supported. You would be running grep rooted at your HOME directory.")))
         (proj-root (project-root proj))
         (default-directory (expand-file-name proj-root)))
    (apply f args)))
(advice-add 'grep :around #'my/grep-around)

;; Make the grep window always shown at the bottom.
(add-to-list
 'display-buffer-alist
 `(,(rx string-start "*grep*" string-end)
   (display-buffer-reuse-window display-buffer-in-side-window)
   (side . bottom)
   (window-height . 0.33)))

(provide 'init-grep-mode)
;;; init-grep-mode.el ends here
