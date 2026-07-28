fundamental-mode ;; Available everywhere

(today
 (format-time-string "%Y-%m-%d")
 :ann "Today's date"
 :doc "Insert today's date")

emacs-lisp-mode

(elispfeature
 (l
  ";;; " (p (file-name-base (buffer-file-name)) file) ".el --- " (s file) ".el -*- lexical-binding: t -*-" n
  ";;; Commentary:" n
  ";;; Code:" n
  n
  r
  n
  n
  "(provide '" (s file) ")" n
  ";;; " (s file) ".el ends here" n
  )
 :ann "elispfeature"
 :doc "elispfeature")

