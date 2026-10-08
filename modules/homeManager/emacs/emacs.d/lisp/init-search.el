;;; init-search.el --- init-search.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Show the order of the match and the total number of matches in the echo area.
 ;; Note that evil-mode does not support this as of 2026-10-09.
 ;; There is an unmerged PR for this.
 ;; https://github.com/emacs-evil/evil/pull/1992
 ;; I downloaded the patch and applied in Nix.
 isearch-lazy-count t
 ;; Never wrap
 isearch-wrap-pause nil
 ;; Do not clean up highlighting after search exits.
 ;; Clean up manually with M-x lazy-highlight-cleanup
 ;; Note that evil-mode does not respect this variable as of 2026-10-09.
 ;; And there is no PR for this.
 ;; We applied a patch in Nix to address this.
 lazy-highlight-cleanup nil
 ;; Highlight all results in the buffer in the current window,
 ;; instead of only in the visible window.
 lazy-highlight-buffer t)

(provide 'init-search)
;;; init-search.el ends here
