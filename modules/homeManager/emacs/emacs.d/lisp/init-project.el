;;; init-project.el --- init-project.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; The default implementation of project-buffers looks at default-directory of the buffer.
;; If the value of default-directory matches the project-root, then it is considered as a project buffer.
;; This behavior is not desirable because when we hit C-x C-b the buffer list inherits the default-directory of the current buffer.
;; This makes the buffer list a project buffer of the current project.
;;
;; Given that special buffers like the buffer list, scratch has no file associated with them,
;; a simple heuristic is to also check buffer-file-name of the buffer.
(defun my/project-buffers-filter-return (buffers)
  "An :filter-return advice to project-buffers.
It calls function `buffer-file-name' for each buffer in BUFFERS,
and ensures it is non-nil."
  (seq-filter (lambda (b) (buffer-file-name b)) buffers))

(with-eval-after-load 'project
  (advice-add 'project-buffers :filter-return #'my/project-buffers-filter-return))

(provide 'init-project)
;;; init-project.el ends here
