;;; init-project.el --- init-project.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; The default implementation of project-buffers looks at `default-directory' of the buffer.
;; If the value of `default-directory' matches `project-root', then it is considered as a project buffer.
;; This behavior is not desirable because when we hit C-x C-b the buffer list inherits the default-directory of the current buffer.
;; This makes the buffer list a project buffer of the current project.
;;
;; Given that special buffers like the buffer list, scratch has no file associated with them,
;; a simple heuristic is to also check buffer-file-name of the buffer.
;;
;;; Code:

(defun my/project-buffers-filter-return (buffers)
  "An :filter-return advice to `project-buffers'.
It calls function `buffer-file-name' for each buffer in BUFFERS,
and ensures it is non-nil."
  (seq-filter (lambda (b) (buffer-file-name b)) buffers))

(with-eval-after-load 'project
  (advice-add 'project-buffers :filter-return #'my/project-buffers-filter-return)
  (keymap-set project-prefix-map "m" #'ghostel-project)
  (keymap-set project-prefix-map "M" #'ghostel-project-list-buffers)
  (keymap-set project-prefix-map "v" #'magit-project-status)
  (keymap-set project-prefix-map "V" #'project-vc-dir)
  ;; FIXME: `project-find-regexp' was omitted. Bring it back.
  (setq
   project-switch-commands
   '((ghostel-project-list-buffers "Ghostel buffers")
     (ghostel-project "Ghostel")
     (project-find-file "Find file")
     (project-find-dir "Find directory")
     (magit-project-status "Magit")
     (project-vc-dir "VC-Dir")
     ;; project-any-command was omitted.
     ;; I haven't figured the use case of it.
     )))

(provide 'init-project)
;;; init-project.el ends here
