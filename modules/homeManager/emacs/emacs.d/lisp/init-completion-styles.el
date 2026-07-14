;;; -*- lexical-binding: t -*-

(use-package
 orderless
 :ensure nil
 :custom
 ;; Use Orderless everything.
 (completion-styles '(orderless basic))
 ;; It is known that gnus will modify completion-category-defaults to add (email (styles substring partial-completion)).
 ;; But it is not a big deal because I do not complete email, at least for now.
 ;;
 ;; For file, Orderless cannot be used because we need to consider the compatibility with TRAMP.
 (completion-category-defaults '((file (styles partial-completion)))))

(provide 'init-completion-styles)
