;;; my-evil.el --- my-evil.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;;###autoload
(defun my/evil-normal-p ()
  "Return non-nil if Evil-Mode normal state should be the default."
  (cond
   ((derived-mode-p 'conf-mode) t)
   ((derived-mode-p 'prog-mode) t)
   ((derived-mode-p 'text-mode) t)
   ((derived-mode-p 'diff-mode) nil)
   ((derived-mode-p 'special-mode) nil)
   ;; When I view a PDF file via a Dired buffer.
   ((derived-mode-p 'doc-view-mode) nil)
   ;; When I view an image file via a Dired buffer.
   ((derived-mode-p 'image-mode) nil)
   ;; When I view a archive file via a Dired buffer.
   ((derived-mode-p 'archive-mode) nil)
   ((buffer-file-name) t)
   (t nil)))

(provide 'my-evil)
;;; my-evil.el ends here
