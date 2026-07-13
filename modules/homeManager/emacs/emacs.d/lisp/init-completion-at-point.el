;;; -*- lexical-binding: t -*-

(use-package
 corfu
 :hook ((prog-mode . corfu-mode)
        (text-mode . corfu-mode))
 :init
 (setq
  ;; Preselect the prompt, that is, what was typed.
  ;; Use corfu-next select the first candidate.
  corfu-preselect 'prompt)
 :config
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

(use-package
 corfu-auto
 :after (corfu)
 :init
 (setq
  corfu-auto t
  corfu-auto-delay 0.1
  ;; Trigger with 1 character.
  corfu-auto-prefix 1
  ;; Printable ASCII characters, with ` '"()[]{}` removed.
  corfu-auto-trigger "!#$%&*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\\^_`abcdefghijklmnopqrstuvwxyz|~"))

(use-package
 corfu-popupinfo
 :after (corfu)
 :init
 (setq
  corfu-popupinfo-delay '(0.1 . 0.1))
 :config
 (corfu-popupinfo-mode 1))

(provide 'init-completion-at-point)
