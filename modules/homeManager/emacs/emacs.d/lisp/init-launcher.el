;;; init-launcher.el --- init-launcher.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defvar my/rime-cangjie-dict-yaml)
(defvar my/rime-user-directory)
(declare-function calc-load-everything "calc-ext")
(declare-function math-check-unit-name "calc-units")
(declare-function math-const-var "calc-ext")
(declare-function math-format-value "calc")
(declare-function my/currency-convert "init-calc")
(declare-function my/currency-convert-all "init-calc")
(declare-function my/currency-decimal-p "init-calc")
(declare-function my/currency-syntactically-valid-currency-p "init-calc")
(declare-function my/rime-cangjie-lookup "my-rime")
(declare-function my/uuid-to-string "my-rng")
(declare-function my/uuid4-bytes "my-rng")

(defun my/launcher--calc-no-unbound-vars (expr)
  "Return non-nil if EXPR contains no unbound variables."
  (if (null expr)
      t
    (if (eq (car-safe expr) 'var)
        ;; inf is a bound var.
        (or (math-const-var expr) (math-check-unit-name expr))
      (and
       (my/launcher--calc-no-unbound-vars (car-safe expr))
       (my/launcher--calc-no-unbound-vars (cdr-safe expr))))))

(defun my/launcher-source--calc-eval (input)
  "Invoke `calc-eval' with INPUT and simplify units."
  (require 'calc)
  (require 'calc-ext)
  (let ((inhibit-message t))
    (calc-load-everything))
  (let* ((prompt (string-trim input)))
    (when (not (string-empty-p prompt))
      (let* ((raw (calc-eval (format "usimplify(%s)" prompt) 'raw)))
        (pcase raw
          ;; (calc-eval "..." 'raw) returns (error-code "error-message")
          (`(,(pred integerp) ,(pred stringp))
           nil)
          ((pred my/launcher--calc-no-unbound-vars)
           (list (math-format-value raw)))
          (_
           nil))))))

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

(defun my/launcher-source--curr (input)
  "Convert an amount in one currency to another.

INPUT is either one of the following forms:
1. DECIMAL SOURCE-CURRENCY
2. DECIMAL SOURCE-CURRENCY TARGET-CURRENCY"
  (let* ((input (string-trim input))
         (parts (string-split input))
         (length-parts (length parts)))
    (when (or (eql length-parts 2) (eql length-parts 3))
      (let* ((decimal (nth 0 parts))
             (source-currency (upcase (nth 1 parts)))
             (target-currency (and (eql length-parts 3) (upcase (nth 2 parts)))))
        (when (and (my/currency-decimal-p decimal) (my/currency-syntactically-valid-currency-p source-currency))
          (if (and target-currency (my/currency-syntactically-valid-currency-p target-currency))
              (list (my/currency-convert decimal source-currency target-currency))
            (my/currency-convert-all decimal source-currency)))))))

(defun my/launcher-source--web-search-by-query (format-string query-name)
  "Build a query WITH QUERY-NAME and build a URL with FORMAT-STRING."
  (lambda (input)
    (let* ((query (string-trim input))
           (url (format format-string
                        (url-build-query-string (list (list query-name query))))))
      (list (propertize url 'multi-category `(url . ,url))))))

(defun my/launcher-source--fan-out (&rest funs)
  "Call each function in FUNS and combine the results."
  (lambda (input)
    (seq-mapcat (lambda (fun) (funcall fun input)) funs)))

(defun my/launcher-make-sync-collection (fun)
  "Turn FUN into a programmed completion collection function."
  (lambda (input _pred flag)
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
         (collection (my/launcher-make-sync-collection
                      (my/launcher-source--fan-out
                       #'my/launcher-source--calc-eval
                       (my/launcher-source--by-keyword
                        "uuid" #'my/launcher-source--uuid
                        "cj" #'my/launcher-source--cj
                        "curr" #'my/launcher-source--curr
                        "jyut" (my/launcher-source--web-search-by-query "https://jyut.net/query?%s" "q")
                        "jwt" (my/launcher-source--web-search-by-query "https://jwt.io/#%s" "id_token")
                        "pypi" (my/launcher-source--web-search-by-query "https://pypi.org/search/?%s" "q")
                        "python" (my/launcher-source--web-search-by-query "https://docs.python.org/3/search.html?%s" "q")
                        "hm" (my/launcher-source--web-search-by-query "https://home-manager-options.extranix.com/?%s" "query")
                        "pkgs" (my/launcher-source--web-search-by-query "https://search.nixos.org/packages?channel=unstable&%s" "query")
                        "nixos" (my/launcher-source--web-search-by-query "https://search.nixos.org/options?channel=unstable&%s" "query")
                        "noogle" (my/launcher-source--web-search-by-query "https://noogle.dev/q/?limit=100&%s" "term")
                        "npm" (my/launcher-source--web-search-by-query "https://www.npmjs.com/search?%s" "q"))))))
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
   my/rime-cangjie-dict-yaml "cangjie5_hk.dict.yaml"))

(provide 'init-launcher)
;;; init-launcher.el ends here
