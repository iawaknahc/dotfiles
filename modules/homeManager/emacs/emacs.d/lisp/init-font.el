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
 ;; Use the default font if it has the glyph.
 use-default-font-for-symbols t)

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
                                 ;; This range is `mahjong-tile'.
                                 ;; See another comment in this file for details.
                                 ((#x1F000 . #x1F02F) . "Noto Sans Symbols 2")
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
      (set-fontset-font fontset (car entry) (font-spec :family (cdr entry)) for-all-frames 'prepend))))

(defun my/configure-nerd-font (fontset)
  "Configure FONTSET so that Symbols Nerd Font Mono is used to display symbols."
  (let* ((for-all-frames nil)
         (nerd-font (font-spec :family "Symbols Nerd Font Mono")))
    ;; U+E000 to U+F8FF is Private Use Area in Basic Multilingual Plane.
    (set-fontset-font fontset '(#xE000 . #xF8FF) nerd-font for-all-frames 'prepend)
    ;; U+F0000 to U+FFFFD is Supplementary Private Use Area-A
    (set-fontset-font fontset '(#xF0000 . #xFFFFD) nerd-font for-all-frames 'prepend)))

;; Create a new fontset for face `variable-pitch'.
(new-fontset "-*-*-*-*-*-*-*-*-*-*-*-*-fontset-proportional" '())
(my/configure-noto-font "fontset-proportional")
(my/configure-nerd-font "fontset-proportional")

(my/configure-noto-font "fontset-default")
(let* ((for-all-frames nil)
       (jetbrains-mono (font-spec :family "JetBrains Mono NL"))
       (noto-sans-mono-cjk-hk (font-spec :family "Noto Sans Mono CJK HK"))
       (noto-sans-mono-cjk-jp (font-spec :family "Noto Sans Mono CJK JP"))
       (noto-sans-mono-cjk-kr (font-spec :family "Noto Sans Mono CJK KR"))
       (julia-mono (font-spec :family "JuliaMono"))
       (lxgw-wenkai-mono-tc (font-spec :family "LXGW WenKai Mono TC"))
       (jigmo1 (font-spec :family "Jigmo"))
       (jigmo2 (font-spec :family "Jigmo2"))
       (jigmo3 (font-spec :family "Jigmo3")))
  (set-fontset-font "fontset-default" '(#x0000 . #x10ffff)      jetbrains-mono         for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'han                      jigmo1                 for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'han                      jigmo2                 for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'han                      jigmo3                 for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'ideographic-description  noto-sans-mono-cjk-hk  for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'cjk-misc                 noto-sans-mono-cjk-hk  for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'kana                     noto-sans-mono-cjk-jp  for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'bopomofo                 noto-sans-mono-cjk-hk  for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'kanbun                   noto-sans-mono-cjk-jp  for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'hangul                   noto-sans-mono-cjk-kr  for-all-frames 'prepend)
  (set-fontset-font "fontset-default" 'han                      noto-sans-mono-cjk-hk  for-all-frames 'prepend)
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
  (set-fontset-font "fontset-default" '(#x1F000 . #x1F02F)      lxgw-wenkai-mono-tc    for-all-frames 'prepend))
(my/configure-nerd-font "fontset-default")

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
   :weight 'light))

(provide 'init-font)
;;; init-font.el ends here
