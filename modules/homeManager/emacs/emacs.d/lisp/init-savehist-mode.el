;;; init-savehist-mode.el --- init-savehist-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Save every minute.
;; The default is every 5 minutes.
(setq savehist-autosave-interval 60)
(add-hook 'after-init-hook #'savehist-mode)

(provide 'init-savehist-mode)
;;; init-savehist-mode.el ends here
