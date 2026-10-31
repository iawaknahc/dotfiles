;;; init-completion-at-point.el --- init-completion-at-point.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(autoload 'corfu-sort-length-alpha "corfu" "Run (require corfu) to see the actual documentation")
(setq
 ;; Preselect the prompt, that is, what was typed.
 ;; Use corfu-next select the first candidate.
 corfu-preselect 'prompt
 ;; The default is 100, which is too large.
 corfu-max-width 50
 ;; cape-capf-super unconditionally set :display-sort-function to identity.
 ;; So we revert to use the default sort function.
 corfu-sort-override-function #'corfu-sort-length-alpha)

(with-eval-after-load 'corfu
  ;; By default, <TAB> is bound to `corfu-complete'.
  ;; When no candidate is selected, `corfu-complete' calls `corfu-expand'.
  ;; When no candidate is selected, `corfu-expand' expands the common prefix of all candidates.
  ;; When a candidate is selected, `corfu-expand' calls `corfu-complete'.
  ;; When a candidate is selected, `corfu-complete' calls `corfu-insert'.
  ;; When a candidate is selected, `corfu-insert' inserts the candidate.
  ;; Therefore, <TAB> does the following
  ;; 1. When no candidate is selected, expands the common prefix of all candidates.
  ;; 2. Otherwise, inserts the selected candidate.
  (keymap-unset corfu-map "<up>") ; <up> is an alias of C-p.
  (keymap-unset corfu-map "<down>") ; <down> is an alias of C-n.
  (keymap-unset corfu-map "M-n") ; M-n is an alias of C-n.
  (keymap-unset corfu-map "M-p") ; M-p is an alias of C-p.
  (keymap-unset corfu-map "M-SPC") ; M-SPC is Spotlight on macOS.
  (keymap-unset corfu-map "C-M-i") ; `C-M-i` is completion-at-point.
  (keymap-unset corfu-map "M-g") ; M-g is corfu-info-location, which I do not use.
  (keymap-unset corfu-map "M-h") ; M-g is corfu-info-documentation, which I do not use.
  (keymap-unset corfu-map "<remap> <move-beginning-of-line>")
  (keymap-unset corfu-map "<remap> <move-end-of-line>"))

;; Enable Corfu mode in minibuffer where completion-at-point-functions is set, and in all buffers.
;; Previously I just enabled it in text-mode and prog-mode.
;; It does not come with an API to enable in minibuffer specifically.
;; So global-corfu-mode has to be used.
;; Enable in the minibuffer is essential for commands like M-:
(add-hook 'after-init-hook #'global-corfu-mode)

(setq
 corfu-auto t
 ;; FIXME: corfu-auto-delay seems to have timing issue.
 ;; If I set corfu-auto-delay to 0.1, in the scratch buffer.
 ;; 1. I type ., see the candidates from `elisp-completion-at-point'.
 ;; 2. I type /, see nothing, while I expect to see candidates from `cape-file'.
 ;;
 ;; If corfu-auto-delay is 0 or 0.2, or 0.3, this issue does not appear.
 corfu-auto-delay 0.2
 ;; Start auto completion when there is 1 character before point.
 corfu-auto-prefix 1
 ;; No characters can override `corfu-auto-prefix'.
 corfu-auto-trigger "")

(setq corfu-popupinfo-delay '(0.1 . 0.1))
(add-hook 'after-init-hook #'corfu-popupinfo-mode)

(provide 'init-completion-at-point)
;;; init-completion-at-point.el ends here
