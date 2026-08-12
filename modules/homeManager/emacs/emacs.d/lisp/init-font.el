;;; init-font.el --- init-font.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/configure-nerd-font (fontset)
  "Configure FONTSET so that Symbols Nerd Font Mono is used to display symbols."
  (let* ((for-all-frames nil)
         (nerd-font (font-spec :family "Symbols Nerd Font Mono" :weight 'regular)))
    (set-fontset-font fontset '(#x23FB . #x23FE) nerd-font for-all-frames 'prepend)
    (set-fontset-font fontset '(#x2500 . #x259F) nerd-font for-all-frames 'prepend)
    (set-fontset-font fontset #x2630 nerd-font for-all-frames 'prepend)
    (set-fontset-font fontset #x2665 nerd-font for-all-frames 'prepend)
    (set-fontset-font fontset #x26A1 nerd-font for-all-frames 'prepend)
    (set-fontset-font fontset '(#x276C . #x2771) nerd-font for-all-frames 'prepend)
    (set-fontset-font fontset '(#x2800 . #x28FF) nerd-font for-all-frames 'prepend)
    (set-fontset-font fontset #x2B58 nerd-font for-all-frames 'prepend)
    ;; U+E000 to U+F8FF is Private Use Area in Basic Multilingual Plane.
    (set-fontset-font fontset '(#xE000 . #xF8FF) nerd-font for-all-frames 'prepend)
    ;; U+F0000 to U+FFFFD is Supplementary Private Use Area-A
    (set-fontset-font fontset '(#xF0000 . #xFFFFD) nerd-font for-all-frames 'prepend)))

;; Configure the fontset "fontset-default" to support Nerd Font.
;; This has no effect unless some packages use faces other than `default' or `variable-pitch'.
(my/configure-nerd-font "fontset-default")

;; Create a new fontset "fontset-monospace" to be used by the face `default'.
;; Since we configure the entire range of codepoints, the fontset "fontset-default" should never be fallen back to.
(new-fontset "-*-*-*-*-*-*-*-*-*-*-*-*-fontset-monospace" '())
(let* ((for-all-frames nil)
       (jetbrains-mono (font-spec :family "JetBrains Mono NL" :weight 'light :size 13))
       (source-han-mono-hc (font-spec :family "Source Han Mono HC" :weight 'light :size 13)))
  ;; Use Source Han Mono HC for all codepoints.
  (set-fontset-font "fontset-monospace" '(#x0 . #x10FFFF) source-han-mono-hc for-all-frames 'prepend)
  ;; But for ASCII range, use JetBrains Mono because it looks much nicer than Source Han Mono.
  (set-fontset-font "fontset-monospace" 'latin jetbrains-mono for-all-frames 'prepend))
(my/configure-nerd-font "fontset-monospace")

;; Create a new fontset "fontset-proportional" to be used by the face `variable-pitch'.
;; Since we configure the entire range of codepoints, the fontset "fontset-default" should never be fallen back to.
(new-fontset "-*-*-*-*-*-*-*-*-*-*-*-*-fontset-proportional" '())
(let* ((for-all-frames nil)
       (source-han-sans (font-spec :family "Source Han Sans" :weight 'normal :size 16)))
  ;; Use Source Han Sans for all codepoints.
  (set-fontset-font "fontset-proportional" '(#x0 . #x10FFFF) source-han-sans for-all-frames 'prepend))
(my/configure-nerd-font "fontset-proportional")

;; Cause all frames to use the fontset "fontset-monospace" by default.
;; This is necessary because calling `set-face-attribute' on face `default' only works for `latin'.
;; I did not dig into why.
(add-to-list 'default-frame-alist '(font . "fontset-monospace"))
;; Assign the faces to their fontsets.
(let* ((for-all-frames nil))
  (set-face-attribute
   'default
   for-all-frames
   :font "fontset-monospace"
   :height 130)
  (set-face-attribute
   'variable-pitch
   for-all-frames
   :font "fontset-proportional"
   :height 160))

(setq
 ;; Customize the sample text so that it includes:
 ;; 1. All uppercase and lowercase English characters.
 ;; 2. All digits.
 ;; 3. A few CJK characters.
 ;; 4. An emoji.
 ;; 5. A Nerd Font symbol.
 list-faces-sample-text "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 你好世界 こんにちは 😀 ♥ ")

(provide 'init-font)
;;; init-font.el ends here
