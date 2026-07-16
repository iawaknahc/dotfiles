;;; init-electric-pair-mode.el --- init-electric-pair-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package
 elec-pair
 :ensure nil
 :hook ((prog-mode . electric-pair-local-mode)))

(provide 'init-electric-pair-mode)
;;; init-electric-pair-mode.el ends here
