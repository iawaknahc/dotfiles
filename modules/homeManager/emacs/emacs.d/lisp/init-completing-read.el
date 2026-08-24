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
 ;;
 ;; Previously I set vertico-preselect to first.
 ;; But when I hit C-x d, I want to press RET immediately to open the directory with Dired.
 ;; Thus, the default value directory probably is the best value.
 vertico-preselect 'directory
 vertico-multiform-commands
 ;; Make C-c C-c on a headline or C-c C-q preselect the prompt by default.
 ;; So C-c C-c on a headline and then press RET immediately does not insert the first arbitrary tag.
 `((org-set-tags-command . ((vertico-preselect . prompt)))
   (org-ctrl-c-ctrl-c . ((vertico-preselect . prompt)))))

(add-hook 'after-init-hook #'vertico-mode)
(add-hook 'after-init-hook #'vertico-multiform-mode)

(provide 'init-completing-read)
;;; init-completing-read.el ends here
