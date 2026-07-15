;;; init-backup-files.el --- init-backup-files.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 emacs
 :custom
 ;; Ask Emacs not to write files without `~` appended.
 (make-backup-files nil))

(provide 'init-backup-files)
;;; init-backup-files.el ends here
