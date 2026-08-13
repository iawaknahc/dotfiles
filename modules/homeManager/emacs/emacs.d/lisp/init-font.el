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
 list-faces-sample-text "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789 你好世界 こんにちは 😀 ♥ "
 ;; Ask Emacs to respect fontset for script `symbol'.
 ;; However, it does not seem to work as intended.
 ;; For example, JetBrains Mono has glyph for U+2208 whose script is `symbol'.
 ;; I expect Noto Sans Symbols 2 should be used, but it is not the case.
 use-default-font-for-symbols nil)

(defconst my/noto-font-mapping '((latin . "Noto Sans")
                                 (phonetic . "Noto Sans")
                                 (greek . "Noto Sans")
                                 (coptic . "Noto Sans Coptic")
                                 (cyrillic . "Noto Sans")
                                 (armenian . "Noto Sans Armenian")
                                 (hebrew . "Noto Sans Hebrew")
                                 (vai . "Noto Sans Vai")
                                 (arabic . "Noto Sans Arabic")
                                 (syriac . "Noto Sans Syriac")
                                 (thaana . "Noto Sans Thaana")
                                 (devanagari . "Noto Sans Devanagari")
                                 (bengali . "Noto Sans Bengali")
                                 (gurmukhi . "Noto Sans Gurmukhi")
                                 (gujarati . "Noto Sans Gujarati")
                                 (oriya . "Noto Sans Oriya")
                                 (tamil . "Noto Sans Tamil")
                                 (telugu . "Noto Sans Telugu")
                                 (kannada . "Noto Sans Kannada")
                                 (malayalam . "Noto Sans Malayalam")
                                 (sinhala . "Noto Sans Sinhala")
                                 (thai . "Noto Sans Thai")
                                 (lao . "Noto Sans Lao")
                                 (tibetan . "Noto Serif Tibetan")
                                 (burmese . "Noto Sans Myanmar")
                                 (georgian . "Noto Sans Georgian")
                                 (ethiopic . "Noto Sans Ethiopic")
                                 (cherokee . "Noto Sans Cherokee")
                                 (canadian-aboriginal . "Noto Sans Canadian Aboriginal")
                                 (ogham . "Noto Sans Ogham")
                                 (runic . "Noto Sans Runic")
                                 (tagalog . "Noto Sans Tagalog")
                                 (hanunoo . "Noto Sans Hanunoo")
                                 (buhid . "Noto Sans Buhid")
                                 (tagbanwa . "Noto Sans Tagbanwa")
                                 (khmer . "Noto Sans Khmer")
                                 (mongolian . "Noto Sans Mongolian")
                                 (limbu . "Noto Sans Limbu")
                                 (buginese . "Noto Sans Buginese")
                                 (balinese . "Noto Sans Balinese")
                                 (sundanese . "Noto Sans Sundanese")
                                 (batak . "Noto Sans Batak")
                                 (lepcha . "Noto Sans Lepcha")
                                 (tai-le . "Noto Sans Tai Le")
                                 (tai-lue . "Noto Sans New Tai Lue")
                                 (tai-tham . "Noto Sans Tai Tham")
                                 (symbol . "Noto Sans Symbols 2")
                                 (braille . "Noto Sans Symbols 2")
                                 (ideographic-description . "Noto Sans CJK HK")
                                 (cjk-misc . "Noto Sans CJK HK")
                                 (kana . "Noto Sans CJK JP")
                                 (bopomofo . "Noto Sans CJK HK")
                                 (kanbun . "Noto Sans CJK JP")
                                 (han . "Noto Sans CJK HK")
                                 (yi . "Noto Sans Yi")
                                 (syloti-nagri . "Noto Sans Syloti Nagri")
                                 (rejang . "Noto Sans Rejang")
                                 (javanese . "Noto Sans Javanese")
                                 (cham . "Noto Sans Cham")
                                 (tai-viet . "Noto Sans Tai Viet")
                                 (meetei-mayek . "Noto Sans Meetei Mayek")
                                 (hangul . "Noto Sans CJK KR")
                                 (linear-b . "Noto Sans Linear B")
                                 (aegean-number . "Noto Sans Linear B")
                                 (ancient-greek-number . "Noto Sans Symbols 2")
                                 (ancient-symbol . "Noto Sans Symbols 2")
                                 (phaistos-disc . "Noto Sans Symbols 2")
                                 (lycian . "Noto Sans Lycian")
                                 (carian . "Noto Sans Carian")
                                 (old-italic . "Noto Sans Old Italic")
                                 (gothic . "Noto Sans Gothic")
                                 (ugaritic . "Noto Sans Ugaritic")
                                 (old-permic . "Noto Sans Old Permic")
                                 (old-persian . "Noto Sans Old Persian")
                                 (deseret . "Noto Sans Deseret")
                                 (shavian . "Noto Sans Shavian")
                                 (osmanya . "Noto Sans Osmanya")
                                 (osage . "Noto Sans Osage")
                                 (elbasan . "Noto Sans Elbasan")
                                 (caucasian-albanian . "Noto Sans Caucasian Albanian")
                                 (vithkuqi . "Noto Sans Vithkuqi")
                                 (linear-a . "Noto Sans Linear A")
                                 (cypriot-syllabary . "Noto Sans Cypriot")
                                 (palmyrene . "Noto Sans Palmyrene")
                                 (nabataean . "Noto Sans Nabataean")
                                 (phoenician . "Noto Sans Phoenician")
                                 (lydian . "Noto Sans Lydian")
                                 (kharoshthi . "Noto Sans Kharoshthi")
                                 (manichaean . "Noto Sans Manichaean")
                                 (avestan . "Noto Sans Avestan")
                                 (old-turkic . "Noto Sans Old Turkic")
                                 (hanifi-rohingya . "Noto Sans Hanifi Rohingya")
                                 (yezidi . "Noto Serif Yezidi")
                                 (old-sogdian . "Noto Sans Old Sogdian")
                                 (sogdian . "Noto Sans Sogdian")
                                 (chorasmian . "Noto Sans Chorasmian")
                                 (elymaic . "Noto Sans Elymaic")
                                 (old-uyghur . "Noto Serif Old Uyghur")
                                 (brahmi . "Noto Sans Brahmi")
                                 (kaithi . "Noto Sans Kaithi")
                                 (chakma . "Noto Sans Chakma")
                                 (mahajani . "Noto Sans Mahajani")
                                 (sharada . "Noto Sans Sharada")
                                 (khojki . "Noto Sans Khojki")
                                 (khudawadi . "Noto Sans Khudawadi")
                                 (grantha . "Noto Sans Grantha")
                                 (newa . "Noto Sans Newa")
                                 (tirhuta . "Noto Sans Tirhuta")
                                 (siddham . "Noto Sans Siddham")
                                 (modi . "Noto Sans Modi")
                                 (takri . "Noto Sans Takri")
                                 (dogra . "Noto Serif Dogra")
                                 (warang-citi . "Noto Sans Warang Citi")
                                 (dives-akuru . "Noto Serif Dives Akuru")
                                 (nandinagari . "Noto Sans Nandinagari")
                                 (zanabazar-square . "Noto Sans Zanabazar Square")
                                 (soyombo . "Noto Sans Soyombo")
                                 (pau-cin-hau . "Noto Sans Pau Cin Hau")
                                 (bhaiksuki . "Noto Sans Bhaiksuki")
                                 (marchen . "Noto Sans Marchen")
                                 (masaram-gondi . "Noto Sans Masaram Gondi")
                                 (gunjala-gondi . "Noto Sans Gunjala Gondi")
                                 (makasar . "Noto Serif Makasar")
                                 (kawi . "Noto Sans Kawi")
                                 (cuneiform . "Noto Sans Cuneiform")
                                 (cypro-minoan . "Noto Sans Cypro Minoan")
                                 (egyptian . "Noto Sans Egyptian Hieroglyphs")
                                 (mro . "Noto Sans Mro")
                                 (tangsa . "Noto Sans Tangsa")
                                 (bassa-vah . "Noto Sans Bassa Vah")
                                 (pahawh-hmong . "Noto Sans Pahawh Hmong")
                                 (medefaidrin . "Noto Sans Medefaidrin")
                                 (tangut . "Noto Serif Tangut")
                                 (khitan-small-script . "Noto Serif Khitan Small Script")
                                 (nushu . "Noto Sans Nushu")
                                 (duployan-shorthand . "Noto Sans Duployan")
                                 (znamenny-musical-notation . "Noto Znamenny Musical Notation")
                                 (byzantine-musical-symbol . "Noto Music")
                                 (musical-symbol . "Noto Music")
                                 (ancient-greek-musical-notation . "Noto Music")
                                 (kaktovik-numeral . "Noto Sans Symbols 2")
                                 (tai-xuan-jing-symbol . "Noto Sans Symbols 2")
                                 (counting-rod-numeral . "Noto Sans Symbols 2")
                                 (nyiakeng-puachue-hmong . "Noto Serif NP Hmong")
                                 (toto . "Noto Serif Toto")
                                 (wancho . "Noto Sans Wancho")
                                 (nag-mundari . "Noto Sans Nag Mundari")
                                 (mende-kikakui . "Noto Sans Mende Kikakui")
                                 (adlam . "Noto Sans Adlam")
                                 (indic-siyaq-number . "Noto Sans Indic Siyaq Numbers")
                                 (ottoman-siyaq-number . "Noto Serif Ottoman Siyaq")
                                 (mahjong-tile . "Noto Sans Symbols 2")
                                 (domino-tile . "Noto Sans Symbols 2")
                                 (chess-symbol . "Noto Sans Symbols 2")))

(defun my/configure-noto-font (fontset)
  "Configure FONTSET so that all recognized scripts are configured to use Noto.

The list was obtained by `script-representative-chars'.

Some entries at the end of the list are injected at runtime,
and they are not really valid recognized script.
As of Emacs 30.2, they all start with `mathematical-'."
  (let* ((for-all-frames nil))
    (dolist (entry my/noto-font-mapping)
      (set-fontset-font fontset (car entry) (font-spec :family (cdr entry) :weight 'regular) for-all-frames 'prepend))))

(defun my/configure-math-font (fontset)
  "Configure FONTSET so that all Mathematics scripts are configured to use a appropriate font."
  (let* ((for-all-frames nil))
    ;; Reference the block by the codepoint range.
    ;; See https://github.com/emacs-mirror/emacs/blob/emacs-30.2/lisp/international/fontset.el#L883
    (set-fontset-font fontset '(#x1D400 . #x1D7FF) (font-spec :family "Latin Modern Math" :weight 'regular) for-all-frames 'prepend)))

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

(my/configure-noto-font "fontset-default")
(my/configure-math-font "fontset-default")
(my/configure-nerd-font "fontset-default")

;; Create a new fontset "fontset-monospace" to be used by the face `default'.
(new-fontset "-*-*-*-*-*-*-*-*-*-*-*-*-fontset-monospace" '())
(let* ((for-all-frames nil)
       (jetbrains-mono (font-spec :family "JetBrains Mono NL" :weight 'light :size 13)))
  ;; Use JetBrains Mono.
  (set-fontset-font "fontset-monospace" 'latin jetbrains-mono for-all-frames 'prepend))

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
   :font "fontset-default"
   :height 160))

(provide 'init-font)
;;; init-font.el ends here
