;;; init-annotation-function.el --- init-annotation-function.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/marginalia-annotate-binding (command)
  "Annotate COMMAND with all keybindings.

It is like `describe-function', with the following differences:
1. Keybindings involving mouse- and wheel- are excluded.
2. Keybindings involving Super are excluded.
3. Keybindings involving help are excluded.
4. If the command is bound to 10 or more keybindings,
   a replacement annotation is shown.
   This deals with the long list of keybindings of `digit-argument'."
  (when-let* ((symbol (intern-soft command)))
    (let* ((remapped-to (command-remapping symbol)))
      (unless (memq remapped-to '(ignore undefined))
        (when-let* ((keybindings (where-is-internal (or remapped-to symbol) overriding-local-map nil nil))
                    (keybindings (seq-remove (lambda (keybinding)
                                               (or (and (vectorp keybinding) (eq (elt keybinding 0) 'menu-bar))
                                                   (seq-some (lambda (event)
                                                               (and (symbolp event)
                                                                    (string-match-p (rx (or "mouse-" "wheel-")) (symbol-name event))))
                                                             keybinding)
                                                   (seq-some (lambda (event)
                                                               (memq 'super (event-modifiers event)))
                                                             keybinding)
                                                   (seq-some (lambda (event)
                                                               (and (symbolp event)
                                                                    (string-match-p (rx "help") (symbol-name event))))
                                                             keybinding)))
                                             keybindings))
                    (descriptions (seq-map (lambda (keybinding)
                                             (propertize (key-description keybinding) 'face 'marginalia-key))
                                           keybindings)))
          (if (>= (length descriptions) 10)
              (concat " (" (propertize "bound to >= 10 keybindings" 'face 'marginalia-key) ")")
            (concat " (" (string-join descriptions ", ") ")")))))))

(with-eval-after-load 'marginalia
  (advice-add #'marginalia-annotate-binding :override #'my/marginalia-annotate-binding))

;; The documentation says it has to be enabled before the completion UI is used.
;; See https://github.com/minad/marginalia#configuration
(marginalia-mode 1) ; This has to be called eagerly according to the documentation.

(provide 'init-annotation-function)
;;; init-annotation-function.el ends here
