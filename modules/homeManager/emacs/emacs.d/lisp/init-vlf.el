;;; init-vlf.el --- init-vlf.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'vlf-setup)

(setq
 ;; Warn when file larger than 4 MB is about to be visited.
 large-file-warning-threshold (* 4 1000 1000)
 ;; Just open Very Large File with vlf without asking.
 vlf-application 'dont-ask)

(provide 'init-vlf)
;;; init-vlf.el ends here
