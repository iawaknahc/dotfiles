;;; -*- lexical-binding: t -*-

;; The official documentation mentions that
;; describe-bindings can be remapped to embark-bindings.
;; But I prefer the builtin UI.
;;
;; Similarly, embark-prefix-help-command is provided for us to set to prefix-help-command.
;; embark-prefix-help-command and embark-bindings share the same UI.
(use-package
 embark
 :ensure nil
 :bind
 (("C-." . embark-act)
  ("C-;" . embark-dwim))
 :custom
 (embark-auto-prefix-help-delay 0))

(provide 'init-embark)
