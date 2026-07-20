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
  (keymap-unset corfu-map "TAB") ; TAB should be self-inserting.
  (keymap-unset corfu-map "RET") ; RET should be self-inserting.
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
 corfu-auto-delay 0.1

 ;; It is unnecessary to configure corfu-auto-prefix because
 ;; corfu respects :company-prefix-length advertised by the CAPF.
 ;; (corfu-auto-prefix 3)

 ;; Printable ASCII characters from 33 to 126 inclusive.
 corfu-auto-trigger "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")

(setq corfu-popupinfo-delay '(0.1 . 0.1))
(add-hook 'after-init-hook #'corfu-popupinfo-mode)

(provide 'init-completion-at-point)
;;; init-completion-at-point.el ends here
