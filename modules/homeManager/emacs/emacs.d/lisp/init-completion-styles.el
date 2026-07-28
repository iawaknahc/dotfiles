;;; init-completion-styles.el --- init-completion-styles.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/no-filter-try-completion (string collection pred point)
  "Ignore STRING, COLLECTION, PRED, AND POINT.
Just return t."
  t)

(defun my/no-filter-all-completions (string collection pred point)
  "Just call `all-completions' with STRING, COLLECTION, PRED.
POINT is ignored."
  (all-completions string collection pred))

(add-to-list
 'completion-styles-alist
 '(my/no-filter
   my/no-filter-try-completion
   my/no-filter-all-completions
   "Accept all candidates from the collection unfiltered."))

(defun my/orderless-literal-suffix (component)
  "Match COMPONENT as a literal suffix string."
  `(seq (literal ,component) string-end))

(setq
 ;; Use Orderless everything.
 completion-styles '(orderless basic)
 ;; It is known that gnus will modify completion-category-defaults to add (email (styles substring partial-completion)).
 ;; But it is not a big deal because I do not complete email, at least for now.
 ;;
 ;; For file, Orderless cannot be used because we need to consider the compatibility with TRAMP.
 completion-category-defaults
 '((file (styles partial-completion))
   (my/calc (styles my/no-filter)))
 ;; Set the separators to be one or more SPC, underscore, or hyphen.
 ;; The default is one or more SPC, which does not work well for Corfu with auto-completion.
 ;; With underscore and hyphen added, I can type `foo_bar` to means `foo bar`.
 ;; Note that corfu-separator is left unchanged and set to SPC by default.
 orderless-component-separator (rx (+ (in "- _"))))

(with-eval-after-load 'orderless
  ;; Add `foo$` to match the end of the candidate literally.
  ;; No idea why it is not included by default while `^foo` is included.
  (add-to-list 'orderless-affix-dispatch-alist `(?$ . ,#'my/orderless-literal-suffix)))

(provide 'init-completion-styles)
;;; init-completion-styles.el ends here
