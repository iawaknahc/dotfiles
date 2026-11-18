;;; init-dabbrev.el --- init-dabbrev.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/dabbrev-configure ()
  "Configure `dabbrev-case-replace' and `dabbrev-case-distinction'."
  ;; The case of the expansion should be preserved.
  ;; For example, some -> someCamelCaseWord
  (setq-local dabbrev-case-replace nil)
  ;; Expansions with different case are different.
  (setq-local dabbrev-case-distinction nil))

(add-hook 'prog-mode-hook #'my/dabbrev-configure)
(add-hook 'conf-mode-hook #'my/dabbrev-configure)

(provide 'init-dabbrev)
;;; init-dabbrev.el ends here
