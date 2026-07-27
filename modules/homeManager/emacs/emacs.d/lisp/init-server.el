;;; init-server.el --- init-server.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; On macOS, I tried using the Emacs service module of home-manager to
;; run Emacs Macport as a server.
;; When I run emacsclient in a terminal, a terminal Emacs frame is created,
;; while I expect a GUI Emacs frame to be created.
;;
;; I googled and asked LLM but no luck.
;; So I settled with just run Emacs.app manually with Spotlight, and
;; start the Emacs server with `server-mode'.
;; In this setup, emacsclient opens a GUI Emacs frame.
;;
;;; Code:

(defun my/enable-server-mode-after-init ()
  "Call `server-mode' if server is not running already."
  (require 'server)
  (unless (server-running-p)
    (server-mode 1)))

(add-hook 'after-init-hook #'my/enable-server-mode-after-init)

(provide 'init-server)
;;; init-server.el ends here
