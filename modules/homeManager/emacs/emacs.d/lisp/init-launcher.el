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

(defun my/launcher-source--by-keyword (&rest args)
  "Invoke source by keywords in ARGS."
  (let* ((table (make-hash-table :test #'equal)))
    (cl-loop
     for (keyword source) on args by #'cddr
     do (puthash keyword source table))
    (lambda (input)
      (when-let* ((_ (string-match (rx
                                    string-start
                                    (* " ")
                                    (group-n 1 (+ (in "a-zA-Z")))
                                    (group-n 2 (* anychar))
                                    string-end)
                                   input))
                  (keyword (match-string-no-properties 1 input))
                  (prompt (match-string-no-properties 2 input))
                  (prompt (string-trim prompt "[ ]+" ""))
                  (source (gethash keyword table)))
        (funcall source prompt)))))

(defun my/launcher-source--uuid (_input)
  "Generate UUID."
  (let* ((uuid-downcase (my/uuid-to-string (my/uuid4-bytes)))
         (uuid-upcase (upcase uuid-downcase)))
    (list uuid-downcase uuid-upcase)))

(defun my/launcher-source--cj (input)
  "Look up the Cangjie composition of INPUT."
  (let* ((prompt (string-trim input)))
    (when-let* ((result (my/rime-cangjie-lookup prompt)))
      (seq-map (lambda (composition)
                 (format "%s %s" (nth 0 composition) (nth 2 composition)))
               result))))

(defun my/launcher-source--jyut (input)
  "Search the Cantonese pronunciation of INPUT."
  (let* ((query (string-trim input))
         (url (format "https://jyut.net/query?%s"
                      (url-build-query-string (list (list "q" query))))))
    (list (propertize url 'multi-category `(url . ,url)))))

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
                   (category . multi-category)))
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
         (collection (my/launcher-make-sync-collection (my/launcher-source--fan-out
                                                        #'my/launcher-source--calc-eval
                                                        (my/launcher-source--by-keyword
                                                         "uuid" #'my/launcher-source--uuid
                                                         "cj" #'my/launcher-source--cj
                                                         "jyut" #'my/launcher-source--jyut)))))
    (select-frame frame)
    (select-frame-set-input-focus frame)
    (unwind-protect
        (progn
          (let* ((minibuffer-allow-text-properties t)
                 (result (my/completing-read collection)))
            (pcase (get-text-property 0 'multi-category result)
              (`(url . ,url)
               (browse-url url))
              (_
               (kill-new result)))))
      (delete-frame frame))))

(with-eval-after-load 'my-rime
  (setq
   my/rime-user-directory "~/Library/Rime"
   my/rime-cangjie-dict-yaml "cangjie5.base.dict.yaml"))

(provide 'init-launcher)
;;; init-launcher.el ends here
