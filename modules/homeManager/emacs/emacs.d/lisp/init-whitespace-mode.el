;;; init-whitespace-mode.el --- init-whitespace-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-hook 'conf-mode-hook #'whitespace-mode)
(add-hook 'prog-mode-hook #'whitespace-mode)
(add-hook 'text-mode-hook #'whitespace-mode)

(defun my/whitespace-refresh-faces (&rest args)
  "It gets the :background of `default' face.
And then set it as :foreground to `whitespace-space' and `whitespace-tab'.
ARGS is ignored."
  (let* ((bg (face-attribute 'default :background)))
    (custom-set-faces
     `(whitespace-space ((t (:foreground ,bg))))
     `(whitespace-tab ((t (:foreground ,bg)))))))
(my/whitespace-refresh-faces)
(add-hook 'enable-theme-functions #'my/whitespace-refresh-faces)

(setq
 ;; Set this to a very large value so that long lines are not highlighted by default.
 ;; To have long lines highlighted, do this:
 ;; 1. (setq whitespace-line-column 80)
 ;; 2. (whitespace-mode -1)
 ;; 3. (whitespace-mode 1)
 whitespace-line-column 1000

 ;; The two regexps are the same.
 ;; The documentation says that the car is for SPACES and the cdr is for TABS.
 ;; I tried to follow the documentation but I found TABS are not highlighted.
 ;; Therefore, I made them the same, and specify `indentation' in `whitespace-style'.
 ;; This combination finally highlight leading spaces and leading tabs.
 whitespace-indentation-regexp (cons (rx line-start (group-n 1 (+ (in " \t")))) (rx line-start (group-n 1 (+ (in " \t")))))

 whitespace-style
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
   ;; This is possible by the combination of the following:
   ;; 1. Customize `whitespace-indentation-regexp' to target leading and trailing spaces and tabs.
   ;;    Note that the spaces and the tabs must be in the first group.
   ;; 2. Turn on space-mark and tab-mark, so that they are replaced by a visible glyph.
   ;; 3. Customize face `whitespace-space' and `whitespace-tab'.
   ;;    Specifically, we get the :background of `default' and set it as :foreground in the faces.
   ;;    This makes the whitespaces invisible most of the time.
   ;;    They are still visible in an active region.

   tabs ; The presence of this means use whitespace-tab to highlight tabs.
   spaces ; The presence of this means use whitespace-space and whitespace-hspace to highlight spaces.
   newline ; The presence of this means use whitespace-newline to highlight newlines.

   ;; I found it quite distracting to have newline shown.
   ;;newline-mark
   space-mark
   tab-mark

   ;; The rest are about what else to highlight.
   trailing ; This uses whitespace-trailing. It has background color because trailing spaces are unwanted.
   lines-tail ; This uses whitespace-line. It is an underline to show the line is too long.
   missing-newline-at-eof ; This uses whitespace-trailing.
   empty

   big-indent

   indentation
   space-after-tab
   space-before-tab
   ))

(provide 'init-whitespace-mode)
;;; init-whitespace-mode.el ends here.
