;;; init-whitespace-mode.el --- init-whitespace-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Turn on whitespace-mode.
(add-hook 'conf-mode-hook #'whitespace-mode)
(add-hook 'prog-mode-hook #'whitespace-mode)
(add-hook 'text-mode-hook #'whitespace-mode)

(setq
 ;; Set this to a very large value so that long lines are not highlighted by default.
 ;; To have long lines highlighted, do this:
 ;; 1. (setq whitespace-line-column 80)
 ;; 2. (whitespace-mode -1)
 ;; 3. (whitespace-mode 1)
 whitespace-line-column 1000

 ;; I used to use whitespace-mode to visualize whitespaces.
 ;; But its mechanism is based on display-table, all whitespaces in the buffer are visualized.
 ;; That is too noisy.
 ;; To encounter the noise, I hacked the face to make the foreground the same as normal background.
 ;; But this hack fails when the background is not normal background, for example, in Ediff and git-commit buffer.
 whitespace-style
 '(
   ;; According to the documentation, this symbol must be present for the rest to take effect.
   face

   ;; Highlight trailing whitespaces with face `whitespace-trailing'.
   trailing
   ;; Highlight the tail of long line with face `whitespace-line'.
   lines-tail
   ;; Highlight missing newline at end of buffer with face `whitespace-trailing'.
   missing-newline-at-eof
   ;; Highlight blank lines at the beginning or the end of buffer with face `whitespace-empty'.
   empty

   ;; I found it quite distracting in a file with `indent-tabs-mode' on and `tab-width' being 8.
   ;;big-indent
   ))

(provide 'init-whitespace-mode)
;;; init-whitespace-mode.el ends here
