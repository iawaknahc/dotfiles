;;; init-org-mode.el --- init-org-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; To work around a very annoying bug.
 ;; 1. It is in org-mode.
 ;; 2. It is in a src block of emacs-lisp.
 ;; 3. electric-indent-mode is t.
 ;; 4. tab-always-indent is t.
 ;; 5. Type RET
 ;; 6. Nothing happens.
 org-src-tab-acts-natively nil
 ;; Change the indentation added by C-c ' to 0.
 org-src-content-indentation 0
 ;; Do not conceal links.
 org-link-descriptive nil)

(provide 'init-org-mode)
;;; init-org-mode.el ends here
