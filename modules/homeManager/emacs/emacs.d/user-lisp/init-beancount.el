;;; init-beancount.el --- init-beancount.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/beancount-load-tempel-snippets-in-beancount-directory ()
  "Use `load-file' to load the file ~/beancount/tempel-snippets.el."
  (when-let* ((file (expand-file-name "~/beancount/tempel-snippets.el"))
              (_ (file-readable-p file)))
    (load-file file)
    (message "Loaded snippets in %S file" file)))
(add-hook 'after-init-hook #'my/beancount-load-tempel-snippets-in-beancount-directory)

(provide 'init-beancount)
;;; init-beancount.el ends here
