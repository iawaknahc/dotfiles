;;; init-eglot.el --- init-eglot.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/add-before-save-hook-for-eglot-format-buffer ()
  "Invoke `eglot-format-buffer' in `before-save-hook' in a buffer-local fashion."
  (add-hook 'before-save-hook #'eglot-format-buffer nil t))

;; `eglot' can only be run in major modes that have a configured language server.
;; Therefore, we do not use `prog-mode-hook'.
(dolist (hook '(beancount-mode-hook
                go-ts-mode-hook
                python-mode-hook
                python-ts-mode-hook
                fish-mode-hook
                nushell-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

;; For these major modes, ask the language server to format the buffer.
(dolist (hook '(go-ts-mode-hook fish-mode-hook))
  (add-hook hook #'my/add-before-save-hook-for-eglot-format-buffer))

;; In beancount file, beancount-language-server reported aligned balance as inlay hint.
;; The default face has :height 0.8 which breaks the alignment.
;; Therefore, we reset the face to have unspecified :height.
(custom-set-faces
 '(eglot-inlay-hint-face ((t (:inherit shadow)))))

(with-eval-after-load 'eglot
  (setf (alist-get 'beancount-mode eglot-server-programs) '("rass" "beancount"))
  (setf (alist-get 'go-ts-mode eglot-server-programs) '("rass" "go"))
  (setf (alist-get '(python-mode python-ts-mode) eglot-server-programs) '("rass" "python"))
  (setf (alist-get 'fish-mode eglot-server-programs) '("rass" "fish"))
  (setf (alist-get 'nushell-ts-mode eglot-server-programs) '("rass" "nushell")))

(provide 'init-eglot)
;;; init-eglot.el ends here
