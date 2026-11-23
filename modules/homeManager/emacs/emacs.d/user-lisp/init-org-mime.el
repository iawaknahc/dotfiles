;;; init-org-mime.el --- init-org-mime.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar org-mime-export-ascii)
(defvar org-mime-export-options)

;; Make the HTML more relevant for emails.
(setq org-mime-export-options '(
                                :section-numbers nil
                                :with-author nil
                                :with-toc nil))
;; Keep the original text.
;; Export as ASCII may not be a good idea.
;; For example,
;; > Quoted message
;; becomes
;;       Quoted message
;; which is not conventional plaintext emails.
(setq org-mime-export-ascii nil)

(provide 'init-org-mime)
;;; init-org-mime.el ends here
