;;; my-xref.el --- my-xref.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'xref)
(require 'text-property-search)

(defun my/xref--files ()
  "Return the files of the matches in the current *xref* buffer."
  (let (files match)
    (save-excursion
      (save-restriction
        (widen)
        (goto-char (point-min))
        (while (setq match (text-property-search-forward 'xref-item))
          (let ((loc (xref-item-location (prop-match-value match))))
            (when (xref-file-location-p loc)
              (push (xref-file-location-file loc) files))))))
    (or (delete-dups (nreverse files))
        (user-error "No matches in this buffer"))))

;;;###autoload
(defun my/xref-multi-file-replace-regexp-as-diff (regexp to-string)
  "Call `multi-file-replace-regexp-as-diff' with REGEXP and TO-STRING.

Call `my/xref--files' to get FILES."
  (multi-file-replace-regexp-as-diff (my/xref--files) regexp to-string))

(provide 'my-xref)
;;; my-xref.el ends here
