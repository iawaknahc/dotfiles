;;; init-display-sort-function.el --- init-display-sort-function.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq prescient-aggressive-file-save t)
(require 'prescient) ; because prescient-persist-mode is not autoloaded.
(prescient-persist-mode 1)

(setq
 corfu-prescient-enable-filtering nil
 corfu-prescient-override-sorting t)
(corfu-prescient-mode 1)

(setq
 vertico-prescient-enable-filtering nil
 vertico-prescient-override-sorting t)
(vertico-prescient-mode 1)

(provide 'init-display-sort-function)
;;; init-display-sort-function.el ends here
