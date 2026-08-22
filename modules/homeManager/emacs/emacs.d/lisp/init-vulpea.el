;;; init-vulpea.el --- init-vulpea.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 vulpea-db-sync-directories (list "~/org/")
 vulpea-default-notes-directory "~/org/"

 ;; Use fswatch instead of polling to watch external changes.
 vulpea-db-sync-external-method 'fswatch
 ;; Fully async indexing.
 vulpea-db-async-extraction 'full
 ;; Do not index links without square brackets.
 vulpea-db-index-plain-links nil
 ;; Skip `org-mode-hook' while indexing.
 vulpea-db-parse-method 'single-temp-buffer

 vulpea-create-default-template
 (list :file-name "${title}.org"))

(vulpea-db-autosync-mode 1)

(provide 'init-vulpea)
;;; init-vulpea.el ends here
