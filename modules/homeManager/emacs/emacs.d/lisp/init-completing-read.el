;;; init-completing-read.el --- init-completing-read.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; I tried a few combinations:
;; 1. Install vertico-posframe. But the frame becomes invisible if I switch to another Application on macOS.
;; 2. Use vertico-multiform and vertico-buffer. But it becomes overwhelming that I need to choose which command use which configuration.
;;
;; I ended up increase vertico-count from 10 to 20 to make the minibuffer taller to show more candidates.
;; This is important when using consult-buffer, it contains section headers so a few more lines are needed.
;; It is also important to set vertico-resize to nil to make the minibuffer height fixed.
;; I can expect the minibuffer prompt always appear at the same line on the screen.
(setq
 vertico-count 20
 vertico-resize nil
 ;; Previously I set vertico-preselect to prompt.
 ;; But in consult-buffer, if the prompt is preselect, the preview is not the current buffer.
 ;; This is very annoying.
 ;; Also, unlike Corfu, in the minibuffer, I am expected to select something, so it is okay to preselect the first choice.
 vertico-preselect 'first)

(vertico-mode 1)

(provide 'init-completing-read)
;;; init-completing-read.el ends here
