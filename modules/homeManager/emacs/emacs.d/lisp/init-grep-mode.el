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
;;; Code:

(setq
 grep-save-buffers nil
 grep-use-null-device nil
 grep-use-null-filename-separator t
 grep-command "rg --color=auto --no-heading --with-filename --line-number --null --regexp ")

(defun my/grep-around (f &rest args)
  (let* ((proj (project-current))
         (proj-root (or (and proj (project-root proj)) default-directory))
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
