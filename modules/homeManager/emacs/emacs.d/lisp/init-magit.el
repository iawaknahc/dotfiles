;;; init-magit.el --- init-magit.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/git-commit-unfold-diff ()
  "Unfold the diff folded by `git-commit-collapse-diff'."
  (remove-from-invisibility-spec '(git-commit-diff t)))

;; Since Magit 4.6.0, the diff in gitcommit is folded by Magit by default.
;; See https://github.com/magit/magit/commit/e36e64dbd50060fc6f67ad2bba5ff2579531d017
(eval-after-load 'git-commit
  (add-hook 'git-commit-setup-hook #'my/git-commit-unfold-diff t))

(provide 'init-magit)
;;; init-magit.el ends here
