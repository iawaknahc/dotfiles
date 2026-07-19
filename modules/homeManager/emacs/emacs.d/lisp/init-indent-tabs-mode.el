;;; init-indent-tabs-mode.el --- init-indent-tabs-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Turn off indent-tabs-mode.
;; Languages that use tabs, like Go, their major modes will turn it on.
(setq-default indent-tabs-mode nil)

(provide 'init-indent-tabs-mode)
;;; init-indent-tabs-mode.el ends here
