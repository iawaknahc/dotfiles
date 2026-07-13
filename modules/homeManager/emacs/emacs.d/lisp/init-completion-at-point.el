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

(defun my/get-filepath-before-point ()
  "Looking before point and see if there is a filepath.
  Return the filepath if found, otherwise nil."
  (let ((end (point))
        (bol (pos-bol))
        (regexp (rx (or (seq (in "`\"'")
                             (group-n 1
                                      (or "/" "./" "../" "~/")
                                      (zero-or-more (in "- !\"#$%&'()*+,./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"))))
                        (seq (group-n 1
                                      (or "/" "./" "../" "~/")
                                      (zero-or-more (in  "-!\"#$%&'()*+,./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")))))))
        result)
    (save-excursion
     (goto-char bol)
     (while (re-search-forward regexp end t)
       (when (= (match-end 0) end)
         (setq result (buffer-substring-no-properties (match-beginning 1) (match-end 1)))))
     result)))

(defun my/expand-filepath-before-point ()
  "Expand the filepath before point to an absolute path.
  The filepath may or may not exist."
  (let* ((filepath (my/get-filepath-before-point))
         (base-directory (or (and buffer-file-name (file-name-directory buffer-file-name)) default-directory)))
    (if filepath
      (expand-file-name filepath base-directory))))

(defun my/resolve-directory-before-point ()
  "Resolve the filepath representing a directory before point.
  Return /homeless-shelter if no directory is found."
  (let* ((filepath (my/expand-filepath-before-point)))
    (if filepath
      (or (and (file-directory-p filepath) filepath)
          (and (file-directory-p (file-name-directory filepath)) (file-name-directory filepath))
          "/homeless-shelter"))))

(defun my/cape-after-change-major-mode-hook ()
  (add-hook 'completion-at-point-functions #'cape-file nil t))

(use-package
 cape
 :hook (after-change-major-mode-hook . my/cape-after-change-major-mode-hook)
 :config
 (setq
  cape-file-directory #'my/resolve-directory-before-point
  cape-file-prefix '("/" "~/" "./" "../")))

(defun my/elisp-completion-at-point-annotation-function (candidate)
  "Annotate CANDIDATE assuming that CANDIDATE is a string that can be converted to an Elisp symbol."
  (when-let ((sym (intern-soft candidate)))
    (cond
      ((special-form-p sym) "special-form")
      ((primitive-function-p sym) "primitive")
      ((native-comp-function-p sym) "native-comp")
      ((byte-code-function-p sym) "byte-code")
      ((macrop sym) "macro")
      ((commandp sym) "command")
      ((functionp sym) "function")
      ((facep sym) "face")
      ((custom-variable-p sym) "custom-var")
      ((special-variable-p sym) "dynamic-var")
      ((or (local-variable-p sym) (local-variable-if-set-p sym)) "buffer-var")
      ((boundp sym) "variable")
      (t "unknown"))))

(defun my/elisp-completion-at-point-around (capf)
  "Wrap CAPF :annotation-function"
  (cape-wrap-properties capf :annotation-function #'my/elisp-completion-at-point-annotation-function))

(advice-add 'elisp-completion-at-point :around #'my/elisp-completion-at-point-around)

(provide 'init-completion-at-point)
