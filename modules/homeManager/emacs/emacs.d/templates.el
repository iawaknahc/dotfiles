fundamental-mode

(today
 (format-time-string "%Y-%m-%d")
 :ann "Date"
 :doc "Today in ISO 8601 format")

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
 :ann "Elisp"
 :doc "Elisp package template")

