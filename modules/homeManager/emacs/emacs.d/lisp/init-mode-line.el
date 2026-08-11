;;; init-mode-line.el --- init-mode-line.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; The default lighter is " Apheleia".
 ;; It is not informative so hide it.
 apheleia-mode-lighter nil
 ;; The default lighter is " ARev".
 ;; It is not informative so hide it.
 auto-revert-mode-text nil
 ;; The default lighter is " ElDoc".
 ;; It is not informative so hide it.
 eldoc-minor-mode-string nil
 ;; Place the evil state tag at the beginning of the mode line.
 ;; The default value of `before' really means after mode-line-position.
 ;; See https://github.com/emacs-evil/evil/blob/1.14.2/evil-core.el#L405
 evil-mode-line-format '(after . mode-line-buffer-identification)
 ;; mode-line-position has 3 parts,
 ;; namely modeline-percent-position, size-indication-mode, and mode-line-position-column-line-format.
 ;; Customize the first part and the last part to add the brackets.
 ;; This makes the parts of mode-line-position visually grouped.
 mode-line-percent-position '(-5 " [%p")
 mode-line-position-column-line-format '(" %l:%c]"))

;; Turn on `column-number-mode'.
;; This causes `mode-line-position' to use `mode-line-position-column-line-format'.
(add-hook 'after-init-hook #'column-number-mode)
;; Turn on `size-indication-mode'.
;; This causes `mode-line-position' to show " of %I" after percentage.
(add-hook 'after-init-hook #'size-indication-mode)

(with-eval-after-load 'whitespace
  ;; The default lighter is " ws".
  ;; Since we have visible glyphs for whitespace when `whitespace-mode' is enabled,
  ;; the lighter is not informative.
  (setf (alist-get 'whitespace-mode minor-mode-alist) (list "")))

(defun my/mode-line-buffer-identification ()
  "Replace `mode-line-buffer-identification'.

The motivation is that Magit generates very long buffer names when
it prepares the buffers for Ediff.
So we customize `mode-line-buffer-identification' to keep the basename only."
  (let* ((buf-name (buffer-name))
         (basename (file-name-nondirectory buf-name)))
    (propertized-buffer-identification basename)))

;; Customize mode-line-format.
;; Here are the changes:
;; 1. mode-line-buffer-identification is moved to the front.
;;    This makes the buffer easier to identify in Ediff.
;; 2. mode-line-frame-identification is omitted.
;;    Since we are not on Windows, it is just spaces.
;; 3. (vc-mode vc-mode) is omitted.
;; 4. (project-mode-line project-mode-line-format) is omitted.
(setq-default
 mode-line-buffer-identification `(:eval (my/mode-line-buffer-identification))
 mode-line-format
 `("%e"
   mode-line-front-space
   mode-line-buffer-identification
   ;; evil-mode-line-tag is inserted here, after mode-line-buffer-identification
   mode-line-mule-info
   mode-line-client
   mode-line-modified
   mode-line-remote
   mode-line-window-dedicated
   mode-line-position
   mode-line-modes
   mode-line-misc-info
   mode-line-end-spaces))


;; Here is the breakdown of the default mode-line-format.
;; See https://github.com/emacs-mirror/emacs/blob/emacs-30.2/lisp/bindings.el#L699
;;
;;  1. mode-line-front-space
;;     Show " " in GUI, or "-" in terminal.
;;  2. mode-line-mule-info
;;     Show %z which usually is "-"
;;     Show (mode-line-eol-desc) which shows
;;     a. eol-mnemonic-unix, which is ":"
;;     b. eol-mnemonic-mac, which is "(Mac)"
;;     c. eol-mnemonic-dos, which is "(DOS)"
;;  3. mode-line-client
;;     Show nothing if it is not an emacsclient
;;     Show "@" otherwise
;;  4. mode-line-modified
;;     Show %*
;;       "%" => read-only, or modified read-only
;;       "*" => modified
;;       "-" => neither
;;     Show %+
;;       "*" => modified, or modified read-only
;;       "%" => read-only
;;       "-" => neither
;;     For a regular file just visited, it shows "--".
;;     Make a change, then it shows "**".
;;     For a *Help* buffer, it shows "%%".
;;  5. mode-line-remote
;;     Show %@, which shows "@" if `default-directory' is remote,
;;     otherwise "-"
;;  6. mode-line-window-dedicated
;;     Show (mode-line-window-control) which shows
;;     a. "D" if window is strongly dedicated.
;;     b. "d" if window is dedicated.
;;     c. nothing otherwise.
;;  7. mode-line-frame-identification
;;     Show (mode-line-frame-control) which shows
;;     a. " %F  " if running on Windows.
;;        %F shows the frame name.
;;     b. "  " otherwise.
;;  8. mode-line-buffer-identification
;;     Show %12b, which shows the buffer name
;;  9. "   " (Literal 3 spaces)
;; 10. mode-line-position
;;     Show mode-line-percent-position, which show %p
;;     Show mode-line-position-column-line-format, which show " (%l, %c)"
;; 11. evil-mode-line-tag
;;     Show the state tag of evil-mode.
;;     The position is controlled by `evil-mode-line-format'.
;;     The default value of `evil-mode-line-format' is before, which means
;;     after mode-line-position.
;;     See https://github.com/emacs-evil/evil/blob/1.14.2/evil-core.el#L405
;; 12. (project-mode-line project-mode-line-format)
;;     `project-mode-line' is nil by default.
;;      (project-mode-line-format) shows the project name preceded by a space.
;; 13. (vc-mode vc-mode)
;;     Show VC information
;; 14. "  " (Literal 2 spaces)
;; 15. mode-line-modes
;;     Show major mode and minor modes
;; 16. mode-line-misc-info
;;     Show the information of which-function-mode
;;     Show global-mode-string
;;       mu4e uses global-mode-string to show information.
;; 17. mode-line-end-spaces
;;     Show nothing in GUI.
;;     Show "-%-" in terminal.

(provide 'init-mode-line)
;;; init-mode-line.el ends here
