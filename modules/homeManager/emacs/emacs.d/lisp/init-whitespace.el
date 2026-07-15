;;; init-whitespace.el --- init-whitespace.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 whitespace
 :ensure nil
 :hook ((prog-mode . whitespace-mode)
        (text-mode . whitespace-mode))
 :custom-face
 (whitespace-space ((t (:inherit line-number))))
 (whitespace-hspace ((t (:inherit line-number))))
 (whitespace-tab ((t (:inherit line-number))))
 (whitespace-newline ((t (:inherit line-number))))
 :custom
 ;; Set this to a very large value so that long lines are not highlighted by default.
 ;; To have long lines highlighted, do this:
 ;; 1. (setq whitespace-line-column 80)
 ;; 2. (whitespace-mode -1)
 ;; 3. (whitespace-mode 1)
 (whitespace-line-column 1000)
 (whitespace-style
  '(
;; According to the documentation, this symbol must be present for the rest to take effect.
    face

    ;; When tabs, spaces, newline are present, the corresponding faces are used to highlight the characters.
    ;; Since whitespace characters are invisible by default, they seem to have no effects.
    ;;
    ;; But if space-mark, tab-mark, newline-mark are present, the whitespace characters will be replaced by a visible glyph via display table.
    ;; Therefore, the 6 should be present together.
    ;;
    ;; Ideally, it is better to only have leading whitespaces visible, like Neovim listchars.
    ;; The built-in whitespace-mode does not support this, and
    ;; there is no popular package to implement this.
    ;;
    ;; So we made a compromise here.
    ;; We enable the display of all whitespace characters everywhere.
    ;; The default faces inherit from the face shadow, which is used to show comments.
    ;; Having whitespace showing with the same color as comments is definitely unreadable.
    ;;
    ;; In the default group of faces, there are two candidates we may use, namely line-number and glyphless-char
    ;; line-number is the face to draw the line numbers in display-line-numbers-mode.
    ;; It is the most subtle face I can find in the default group.
    ;; glyphless-char is the face to draw character that typically has no glyph.
    ;; glyphless-char by default is (:height 0.6).
    ;; So using it will cause whitespaces to be narrower.
    ;; This is not desirable in editing code in monospace fonts.
    ;; So we ended up using line-number.
    tabs ; The presence of this means use whitespace-tab to highlight tabs.
    spaces ; The presence of this means use whitespace-space and whitespace-hspace to highlight spaces.
    newline ; The presence of this means use whitespace-newline to highlight newlines.
    newline-mark
    space-mark
    tab-mark

    ;; The rest are about what else to highlight.
    trailing ; This uses whitespace-trailing. It has background color because trailing spaces are unwanted.
    lines-tail ; This uses whitespace-line. It is an underline to show the line is too long.
    missing-newline-at-eof ; This uses whitespace-trailing.
    empty
    indentation ; This uses whitespace-indentation. It has no background color.
    big-indent
    space-after-tab ; This uses whitespace-space-after-tab.
    space-before-tab; This uses whitespace-space-before-tab.
    )))

(provide 'init-whitespace)
;;; init-whitespace.el ends here
