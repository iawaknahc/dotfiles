;;; init-embark.el --- init-embark.el -*- lexical-binding: t -*-
;;; Commentary:
;; The official documentation mentions that
;; describe-bindings can be remapped to embark-bindings.
;; But I prefer the builtin UI.
;;
;; Similarly, embark-prefix-help-command is provided for us to set to prefix-help-command.
;; embark-prefix-help-command and embark-bindings share the same UI.
;;; Code:

;; C-c . is bound to `org-timestamp',
;; so we bind to C-c C-. instead.
(keymap-global-set "C-c C-." #'embark-act)
;; C-c ; is bound to `org-toggle-comment',
;; so we bind to C-c C-; instead.
(keymap-global-set "C-c C-;" #'embark-dwim)

(setq embark-auto-prefix-help-delay 0)

(provide 'init-embark)
;;; init-embark.el ends here
