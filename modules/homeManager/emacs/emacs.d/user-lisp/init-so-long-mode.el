;;; init-so-long-mode.el --- init-so-long-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar so-long-target-modes)
(defvar so-long-threshold)

;; Line with more than 4000 bytes are so long.
(setq so-long-threshold 4000)
;; `so-long-predicate' is left as its default `so-long-statistics-excessive-p',
;; which does not need `so-long-max-lines'.
;; The default is (prog-mode css-mode sgml-mode nxml-mode fundamental-mode)
;; As of Emacs 31.1, `css-mode' is a derived mode of `prog-mode'.
;; `sgml-mode' is a derived mode of `text-mode'.
;; `nxml-mode' is a derived mode of `text-mode'.
;; So I replaced them with `conf-mode' and `text-mode'.
(setq so-long-target-modes '(prog-mode conf-mode text-mode fundamental-mode))

(global-so-long-mode 1)

(provide 'init-so-long-mode)
;;; init-so-long-mode.el ends here
