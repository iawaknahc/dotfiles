;;; init-tempel.el --- init-tempel.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(keymap-global-set "C-c C-k" #'tempel-expand)
(with-eval-after-load 'tempel
  (keymap-set tempel-map "<tab>" #'tempel-next)
  (keymap-set tempel-map "S-<tab>" #'tempel-previous))

(provide 'init-tempel)
;;; init-tempel.el ends here
