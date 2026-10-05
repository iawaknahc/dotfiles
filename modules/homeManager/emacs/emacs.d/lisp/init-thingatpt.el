;;; init-thingatpt.el --- init-thingatpt.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(add-hook 'text-mode-hook #'my/thingatpt-mode)
(add-hook 'prog-mode-hook #'my/thingatpt-mode)
(add-hook 'conf-mode-hook #'my/thingatpt-mode)

(provide 'init-thingatpt)
;;; init-thingatpt.el ends here
