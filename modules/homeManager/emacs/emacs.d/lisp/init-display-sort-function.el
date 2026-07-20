;;; init-display-sort-function.el --- init-display-sort-function.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq prescient-aggressive-file-save t)
(add-hook
 'after-init-hook
 (lambda ()
   (require 'prescient) ; because prescient-persist-mode is not autoloaded.
   (prescient-persist-mode 1)))

(setq
 corfu-prescient-enable-filtering nil
 corfu-prescient-override-sorting t)
(add-hook 'after-init-hook #'corfu-prescient-mode)

(setq
 vertico-prescient-enable-filtering nil
 vertico-prescient-override-sorting t)
(add-hook 'after-init-hook #'vertico-prescient-mode)

(provide 'init-display-sort-function)
;;; init-display-sort-function.el ends here
