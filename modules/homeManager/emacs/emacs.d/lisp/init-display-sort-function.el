;;; -*- lexical-binding: t -*-

(use-package
 prescient
 :custom
 (prescient-aggressive-file-save t)
 :config
 (prescient-persist-mode 1))

(use-package
 corfu-prescient
 :after (prescient corfu)
 :custom
 (corfu-prescient-enable-filtering nil)
 (corfu-prescient-override-sorting t)
 :config
 (corfu-prescient-mode 1))

(use-package
 vertico-prescient
 :after (prescient vertico)
 :custom
 (vertico-prescient-enable-filtering nil)
 (vertico-prescient-override-sorting t)
 :config
 (vertico-prescient-mode 1))

(provide 'init-display-sort-function)
