;;; init-project.el --- init-project.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;;; Code:

(with-eval-after-load 'project
  (keymap-set project-prefix-map "g" #'my/lgrep-project)
  (keymap-set project-prefix-map "m" #'ghostel-project)
  (keymap-set project-prefix-map "M" #'ghostel-project-new)
  (keymap-set project-prefix-map "v" #'magit-project-status)
  (keymap-set project-prefix-map "V" #'project-vc-dir)
  ;; Commands that I want to run on project A while I am at project B.
  (setq
   project-switch-commands
   '((ghostel-project "Ghostel")
     (ghostel-project-new "New Ghostel")
     (project-find-file "Find file")
     (project-find-dir "Find directory")
     (my/lgrep-project "Grep")
     (magit-project-status "Magit")
     ;; project-any-command was omitted.
     ;; I haven't figured the use case of it.
     )))

(defun my/project-list-buffers-ibuffer (project &optional files-only)
  "A modified version of `project-list-buffers-ibuffer' that use the same window.

PROJECT and FILES-ONLY are treated the same as in `project-list-buffers-ibuffer'."
  (ibuffer
   nil
   (format "*Ibuffer-%s" (project-name project))
   `((predicate . (and
                   (or ,(not files-only) buffer-file-name)
                   (member (current-buffer)
                           (project-buffers ',project)))))))

(setq
 ;; The default implementation of `project-buffers' uses `default-directory' to
 ;; determine whether a buffer belongs to a project.
 ;; Non-file-visiting buffers like Ibuffer inherit `default-directory' from current buffer.
 ;; Use C-u C-x p C-b to list only file-visiting buffers.
 project-buffers-viewer #'my/project-list-buffers-ibuffer)

(provide 'init-project)
;;; init-project.el ends here
