;;; init-flyspell.el --- init-flyspell.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(with-eval-after-load 'ispell
  (setopt ispell-program-name "hunspell")
  (setopt ispell-dictionary "en_US")
  (rx-let ((en-letter (any
                       ;; The sub-ranges in Unicode Block Basic Latin.
                       (?A . ?Z) (?a . ?z)
                       ;; The sub-ranges in Unicode Block Latin-1 Supplement,
                       ;; excluding the two mathematical symbols.
                       ;; À–Ö
                       (#x00C0 . #x00D6)
                       ;; Ø–ö, skips U+00D7 (×)
                       (#x00D8 . #x00F6)
                       ;; ø–ÿ, skips U+00F7 (÷)
                       (#x00F8 . #x00FF))))
    (setopt ispell-local-dictionary-alist
            ;; Configure English properly so that in an Org buffer with mixed CJK characters with English,
            ;; the CJK characters are not sent to `ispell-program-name' for spell checking.
            `((
               ;; The name of the dictionary
               "en_US"
               ;; The regexp to describe a word in the dictionary
               ,(rx en-letter)
               ;; The regexp to describe a non-word in the dictionary
               ,(rx (not en-letter))
               ;; The regexp to describe characters that can appear inside a word.
               ,(rx (any ?' #x2019))
               ;; MANY-OTHERCHARS-P means whether the characters described
               ;; by the previous regexp can appear multiple times in a word.
               ;; In English, apostrophes typically do not appear multiple times in a word,
               ;; so we set this to nil.
               nil
               ;; The arguments to `ispell-program-name'.
               ("-d" "en_US")
               ;; This flag is not supported by Hunspell.
               ;; See https://github.com/emacs-mirror/emacs/blob/emacs-31.1/lisp/textmodes/ispell.el#L1065
               nil
               ;; The coding
               utf-8)))))

(defun my/flyspell-turn-on-in-text-mode ()
  "Only turn on `flyspell-mode' when `major-mode' is `text-mode'.

Modes like `toml-ts-mode' derive from `text-mode', but
we certainly do not want `flyspell-mode' to run in those modes."
  (when (eq major-mode 'text-mode)
    (flyspell-mode 1)))

(add-hook 'text-mode-hook #'my/flyspell-turn-on-in-text-mode)
(add-hook 'org-mode-hook #'flyspell-mode)
(add-hook 'markdown-ts-mode-hook #'flyspell-mode)
;; I tried flyspell-prog-mode.
;; But without dictionary, many common terms in programming are considered misspelled.
;; For example, "init", "el".
;; (add-hook 'prog-mode-hook #'flyspell-prog-mode)

(provide 'init-flyspell)
;;; init-flyspell.el ends here
