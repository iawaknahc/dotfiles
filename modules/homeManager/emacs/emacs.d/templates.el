fundamental-mode

(today
 (my/call-command :program "snippet.py" :args '("today"))
 :pre (require 'my-lib)
 :ann "Date"
 :doc "Today in ISO 8601 format")

(yesterday
 (my/call-command :program "snippet.py" :args '("yesterday"))
 :pre (require 'my-lib)
 :ann "Date"
 :doc "Yesterday in ISO 8601 format")

(tomorrow
 (my/call-command :program "snippet.py" :args '("tomorrow"))
 :pre (require 'my-lib)
 :ann "Date"
 :doc "Tomorrow in ISO 8601 format")

(thisweek
 (my/call-command :program "snippet.py" :args '("thisweek"))
 :pre (require 'my-lib)
 :ann "Date"
 :doc "This week in ISO week format")

(lastweek
 (my/call-command :program "snippet.py" :args '("lastweek"))
 :pre (require 'my-lib)
 :ann "Date"
 :doc "Last week in ISO week format")

(nextweek
 (my/call-command :program "snippet.py" :args '("nextweek"))
 :pre (require 'my-lib)
 :ann "Date"
 :doc "Next week in ISO week format")

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
