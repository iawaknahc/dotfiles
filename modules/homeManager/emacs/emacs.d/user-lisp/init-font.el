;;; init-font.el --- init-font.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Customize the sample text so that it includes:
 ;; 1. All uppercase and lowercase English characters.
 ;; 2. All digits.
 ;; 3. A few CJK characters.
 ;; 4. An emoji.
 ;; 5. A Nerd Font symbol.
 list-faces-sample-text "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 你好世界 こんにちは 안녕하세요 😀 ♥ "
 ;; Use the default font if it has the glyph.
 use-default-font-for-symbols t)

(defconst my/unicode-korean-ranges
  '((#x1100 . #x11FF)     ; Hangul Jamo
    (#x3130 . #x318F)     ; Hangul Compatibility Jamo
    (#xAC00 . #xD7AF))    ; Hangul Syllables
  "A list of Unicode ranges that should be rendered with a Korean font.

This is needed because Hangul in Noto Sans Mono CJK is 0.92 em wide.

See `my/unicode-cjk-ranges'.")

(defconst my/unicode-cjk-ranges
  '((#x02EA . #x02EB)     ; Spacing Modifier Letters (Bopomofo tone marks only)
    ;;(#x1100 . #x11FF)   ; Hangul Jamo
    (#x2E80 . #x2EFF)     ; CJK Radicals Supplement
    (#x2F00 . #x2FDF)     ; Kangxi Radicals
    (#x2FF0 . #x2FFF)     ; Ideographic Description Characters
    (#x3000 . #x303F)     ; CJK Symbols and Punctuation
    (#x3040 . #x309F)     ; Hiragana
    (#x30A0 . #x30FF)     ; Katakana
    (#x3100 . #x312F)     ; Bopomofo
    ;;(#x3130 . #x318F)   ; Hangul Compatibility Jamo
    (#x3190 . #x319F)     ; Kanbun
    (#x31A0 . #x31BF)     ; Bopomofo Extended
    (#x31C0 . #x31EF)     ; CJK Strokes
    (#x31F0 . #x31FF)     ; Katakana Phonetic Extensions
    (#x3200 . #x32FF)     ; Enclosed CJK Letters and Months
    (#x3300 . #x33FF)     ; CJK Compatibility
    (#x3400 . #x4DBF)     ; CJK Unified Ideographs Extension A
    (#x4E00 . #x9FFF)     ; CJK Unified Ideographs
    (#xA960 . #xA97F)     ; Hangul Jamo Extended-A
    ;;(#xAC00 . #xD7AF)   ; Hangul Syllables
    (#xD7B0 . #xD7FF)     ; Hangul Jamo Extended-B
    (#xF900 . #xFAFF)     ; CJK Compatibility Ideographs
    (#xFE10 . #xFE1F)     ; Vertical Forms
    (#xFE30 . #xFE4F)     ; CJK Compatibility Forms
    (#xFE50 . #xFE6F)     ; Small Form Variants
    (#xFF00 . #xFFEF)     ; Halfwidth and Fullwidth Forms
    (#x16FE2 . #x16FE3)   ; Ideographic Symbols and Punctuation (Han only)
    (#x16FF0 . #x16FF6)   ; Ideographic Symbols and Punctuation (Han only)
    (#x1AFF0 . #x1AFFF)   ; Kana Extended-B
    (#x1B000 . #x1B0FF)   ; Kana Supplement
    (#x1B100 . #x1B12F)   ; Kana Extended-A
    (#x1B130 . #x1B16F)   ; Small Kana Extension
    (#x1F200 . #x1F2FF)   ; Enclosed Ideographic Supplement
    (#x20000 . #x2A6DF)   ; CJK Unified Ideographs Extension B
    (#x2A700 . #x2B73F)   ; CJK Unified Ideographs Extension C
    (#x2B740 . #x2B81F)   ; CJK Unified Ideographs Extension D
    (#x2B820 . #x2CEAF)   ; CJK Unified Ideographs Extension E
    (#x2CEB0 . #x2EBEF)   ; CJK Unified Ideographs Extension F
    (#x2EBF0 . #x2EE5F)   ; CJK Unified Ideographs Extension I
    (#x2F800 . #x2FA1F)   ; CJK Compatibility Ideographs Supplement
    (#x30000 . #x3134F)   ; CJK Unified Ideographs Extension G
    (#x31350 . #x323AF)   ; CJK Unified Ideographs Extension H
    (#x323B0 . #x3347F))  ; CJK Unified Ideographs Extension J
  "A list of Unicode ranges that should be rendered with a CJK font.

Each range has a comment.
If the comment does not end with a bracket,
then the range is actually a Unicode block.
If the comment ends with a bracket,
then the range is a sub-range in a Unicode block.

Last updated for Unicode 18.0.0")

(defun my/configure-nerd-font (fontset)
  "Configure FONTSET so that Symbols Nerd Font Mono is used to display symbols."
  (let* ((for-all-frames nil)
         (nerd-font (font-spec :family "Symbols Nerd Font Mono")))
    ;; U+E000..U+F8FF is Private Use Area in Basic Multilingual Plane.
    (set-fontset-font fontset '(#xE000 . #xF8FF) nerd-font for-all-frames 'prepend)
    ;; U+F0000..U+FFFFD is Supplementary Private Use Area-A
    (set-fontset-font fontset '(#xF0000 . #xFFFFD) nerd-font for-all-frames 'prepend)))

;; Create a new fontset for face `variable-pitch'.
(new-fontset "-*-*-*-*-*-*-*-*-*-*-*-*-fontset-proportional" '())
(my/configure-nerd-font "fontset-proportional")

(let* ((for-all-frames nil)
       (jetbrains-mono (font-spec :family "JetBrains Mono NL"))
       (noto-sans-mono-cjk-hk (font-spec :family "Noto Sans Mono CJK HK RealMono"))
       (julia-mono (font-spec :family "JuliaMono"))
       (gl-mahjongtile-clr-full-width (font-spec :family "GL-MahjongTile-Clr FullWidth"))
       (jigmo1 (font-spec :family "Jigmo RealMono"))
       (jigmo2 (font-spec :family "Jigmo2 RealMono"))
       (jigmo3 (font-spec :family "Jigmo3 RealMono"))
       (d2coding (font-spec :family "D2Coding RealMono")))
  (set-fontset-font "fontset-default" '(#x0000 . #x10ffff)      jetbrains-mono         for-all-frames 'prepend)
  (dolist (range my/unicode-korean-ranges)
    (set-fontset-font "fontset-default" range d2coding for-all-frames 'prepend))
  (dolist (range my/unicode-cjk-ranges)
    (set-fontset-font "fontset-default" range jigmo1 for-all-frames 'prepend))
  (dolist (range my/unicode-cjk-ranges)
    (set-fontset-font "fontset-default" range jigmo2 for-all-frames 'prepend))
  (dolist (range my/unicode-cjk-ranges)
    (set-fontset-font "fontset-default" range jigmo3 for-all-frames 'prepend))
  (dolist (range my/unicode-cjk-ranges)
    (set-fontset-font "fontset-default" range noto-sans-mono-cjk-hk for-all-frames 'prepend))
  (set-fontset-font "fontset-default" 'symbol                   julia-mono             for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'braille                  julia-mono             for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'kaktovik-numeral         julia-mono             for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'tai-xuan-jing-symbol     julia-mono             for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'counting-rod-numeral     julia-mono             for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'domino-tile              julia-mono             for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'chess-symbol             julia-mono             for-all-frames 'prepend)
  ;; We use explicit range instead of `mahjong-tile' because U+1F004 (紅中) is considered as `emoji' by Emacs.
  ;; Without the explicit range, Emacs will a font for `emoji'.
  ;; For some reason, when the emoji font is picked, the codepoint sequence U+1F004 U+FE0E (text-style) is always
  ;; displayed as an emoji even the text-style variant selector is after the codepoint.
  ;; However, if U+1F004 is classified as a `mahjong-tile' in the first place,
  ;; The codepoint sequence U+1F004 U+FE0F (emoji-style) will be displayed as an emoji.
  (set-fontset-font "fontset-default" '(#x1F000 . #x1F02F) gl-mahjongtile-clr-full-width for-all-frames 'prepend))
(my/configure-nerd-font "fontset-default")
(setq face-font-rescale-alist
      '(("-cdac$" . 1.3)
        ("Apple Color Emoji" . 0.94117647)))

;; Assign the faces to their fontsets.
(let* ((for-all-frames nil))
  (set-face-attribute
   'default
   for-all-frames
   :font "fontset-default"
   ;; :fontset is an undocumented feature.
   :fontset "fontset-default"
   :height 130
   ;; Emacs does not support per-font normal and bold weight selection.
   ;; So we pick use the weight of the latin font as the main weight.
   :weight 'light)
  (set-face-attribute
   'variable-pitch
   for-all-frames
   :font "fontset-proportional"
   ;; :fontset is an undocumented feature.
   :fontset "fontset-proportional"
   :height 160
   :weight 'light)
  ;; Make face `fixed-pitch' and face `fixed-pitch-serif' inherit face `default'.
  ;; Themes like Modus expect `fixed-pitch' to be configured by the user.
  (set-face-attribute
   'fixed-pitch
   for-all-frames
   :family 'unspecified
   :inherit 'default)
  (set-face-attribute
   'fixed-pitch-serif
   for-all-frames
   :family 'unspecified
   :inherit 'default))

(provide 'init-font)
;;; init-font.el ends here
