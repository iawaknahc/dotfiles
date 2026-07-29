;;; init-launcher.el --- init-launcher.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/calc-eval (prompt)
  "Invoke `calc-eval' with PROMPT and simplify units."
  (when (not (string-empty-p prompt))
    (let* ((result (calc-eval (format "usimplify(%s)" prompt))))
      (when (stringp result)
        (list result)))))

(defun my/launcher-collection (input)
  "Conform to `consult--dynamic-collection'.
INPUT is the raw user input."
  (let* ((calc-result (my/calc-eval (string-trim input))))
    (or calc-result (list "ERROR"))))

(defun my/launcher-make-frame ()
  "Make a frame suitable for launcher."
  (make-frame `((name . "mylauncher")
                (width . 0.5)
                (height . 20)
                (left . 0.5)
                (top . 0.15)
                (minibuffer . only)
                (unsplittable . t)
                (no-other-frame . t)
                (undecorated . t)
                (auto-raise . t))))

(defun my/launcher ()
  "Open the launcher."
  (interactive)
  (require 'consult)
  (let* ((frame (my/launcher-make-frame)))
    (select-frame frame)
    (select-frame-set-input-focus frame)
    (condition-case err
        (let* (
               ;; We do not need async split.
               (consult-async-split-style nil)
               (result (consult--read
                        (consult--dynamic-collection #'my/launcher-collection
                          :min-input 0
                          :throttle 0
                          :debounce 0)
                        :prompt ""
                        :category 'my/calc)))
          (kill-new result))
      (:success (delete-frame frame))
      (quit (delete-frame frame)))))

(provide 'init-launcher)
;;; init-launcher.el ends here
