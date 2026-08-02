;;; init-tempel.el --- init-tempel.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(keymap-global-set "C-c k" #'tempel-expand)
(with-eval-after-load 'tempel
  (keymap-set tempel-map "TAB" #'tempel-next)
  (keymap-set tempel-map "<backtab>" #'tempel-previous)
  (keymap-set tempel-map "S-TAB" #'tempel-previous))

(provide 'init-tempel)
;;; init-tempel.el ends here
