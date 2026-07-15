;;; init-echo-area.el --- init-echo-area.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 emacs
 :custom
 ;; Echo the incomplete commands after 10ms
 (echo-keystrokes 0.01))

(provide 'init-echo-area)
;;; init-echo-area.el ends here
