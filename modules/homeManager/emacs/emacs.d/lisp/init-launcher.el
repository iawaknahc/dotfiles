;;; init-launcher.el --- init-launcher.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/launcher-source--calc-eval (input)
  "Invoke `calc-eval' with INPUT and simplify units."
  (require 'calc)
  (require 'calc-ext)
  (let ((inhibit-message t))
    (calc-load-everything))
  (let* ((prompt (string-trim input)))
    (when (not (string-empty-p prompt))
      (let* ((result (calc-eval (format "usimplify(%s)" prompt))))
        (when (stringp result)
          (list result))))))

(defun my/launcher-source--fan-out (&rest funs)
  "Call each function in FUNS and combine the results."
  (lambda (input)
    (seq-mapcat (lambda (fun) (funcall fun input)) funs)))

(defun my/launcher-make-sync-collection (fun)
  "Turn FUN into a programmed completion collection function."
  (lambda (input pred flag)
    (pcase flag
      ;; Return t to signify the input should be kept intact.
      ('nil t)
      ;; Run the actual logic to get candidates.
      ('t (funcall fun input))
      ;; Return t to signify we have something to return.
      ('lambda t)
      ;; Return the expected value according to the protocol.
      (`(boundaries . ,suffix) `(boundaries 0 . ,(length suffix)))
      ('metadata `(metadata
                   (category . my/launcher-item)))
      (_ nil))))

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

(defun my/completing-read (collection)
  "Invoke `completing-read' with COLLECTION."
  (completing-read "" collection))

(defun my/launcher ()
  "Open the launcher."
  (interactive)
  (require 'consult)
  (let* ((frame (my/launcher-make-frame))
         (collection (my/launcher-make-sync-collection (my/launcher-source--fan-out #'my/launcher-source--calc-eval))))
    (select-frame frame)
    (select-frame-set-input-focus frame)
    (unwind-protect
        (progn
          (let* ((result (my/completing-read collection)))
            (kill-new result)))
      (delete-frame frame))))

(provide 'init-launcher)
;;; init-launcher.el ends here
