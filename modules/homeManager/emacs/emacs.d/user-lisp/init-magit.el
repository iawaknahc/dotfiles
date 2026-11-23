;;; init-magit.el --- init-magit.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(declare-function git-commit-collapse-diff "git-commit")

;; Since Magit 4.6.0, the diff in gitcommit is folded by Magit by default.
;; See https://github.com/magit/magit/commit/e36e64dbd50060fc6f67ad2bba5ff2579531d017
(with-eval-after-load 'git-commit
  (remove-hook 'git-commit-setup-hook #'git-commit-collapse-diff))

(provide 'init-magit)
;;; init-magit.el ends here
