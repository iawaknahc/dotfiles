;;; init-org-mime.el --- init-org-mime.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Make the HTML more relevant for emails.
 org-mime-export-options '(
                           :section-numbers nil
                           :with-author nil
                           :with-toc nil)
 ;; Keep the original text.
 ;; Export as ASCII may not be a good idea.
 ;; For example,
 ;; > Quoted message
 ;; becomes
 ;;       Quoted message
 ;; which is not conventional plaintext emails.
 org-mime-export-ascii nil)

(provide 'init-org-mime)
;;; init-org-mime.el ends here
