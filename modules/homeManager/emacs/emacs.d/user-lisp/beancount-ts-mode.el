;;; beancount-ts-mode.el --- beancount-ts-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'treesit)

(defconst beancount-ts--font-lock-feature-list
  '(;; level 1
    (comment headline directive)
    ;; level 2
    (string date flag)
    ;; level 3
    (key tag link constant number)
    ;; level 4
    (delimiter))
  "`treesit-font-lock-feature-list' for `beancount-ts-mode'.")

(defconst beancount-ts--font-lock-settings
  (treesit-font-lock-rules

   :language 'beancount
   :feature 'comment
   '((comment) @font-lock-comment-face)

   :language 'beancount
   :feature 'headline
   '((headline) @font-lock-doc-face)

   :language 'beancount
   :feature 'directive
   '(["option"
      "plugin"
      "include"
      "popmeta"
      "pushmeta"
      "poptag"
      "pushtag"
      "balance"
      "open"
      "close"
      "pad"
      "document"
      "note"
      "event"
      "price"
      "commodity"
      "query"
      "custom" ] @font-lock-keyword-face
      (txn "txn" @font-lock-keyword-face))

   :language 'beancount
   :feature 'string
   '([(string)
      (narration)
      (payee)] @font-lock-string-face)

   :language 'beancount
   :feature 'date
   '((date) @font-lock-type-face)

   :language 'beancount
   :feature 'flag
   '((txn "*" @font-lock-delimiter-face)
     (txn "#" @font-lock-warning-face)
     (flag) @font-lock-warning-face)

   :language 'beancount
   :feature 'key
   '((key) @font-lock-property-name-face)

   :language 'beancount
   :feature 'tag
   '((tag) @font-lock-builtin-face)

   :language 'beancount
   :feature 'link
   '((link) @font-lock-builtin-face)

   :language 'beancount
   :feature 'constant
   '([(bool) "NULL"] @font-lock-constant-face)

   :language 'beancount
   :feature 'number
   '([(number)
      (unary_number_expr)
      "("
      ")" ] @font-lock-number-face)

   :language 'beancount
   :feature 'delimiter
   '(["{" "}"] @font-lock-bracket-face
     [":" (at) (atat)] @font-lock-delimiter-face
     (compound_amount "#" @font-lock-delimiter-face)))
  "`treesit-font-lock-settings' for `beancount-ts-mode'.")

(defconst beancount-ts--outline-regexp
  (rx (or (>= 3 ";") (>= 1 "*")) " ")
  "`outline-regexp' for `beancount-ts-mode'.")

(defconst beancount-ts--defun-type-regexp
  (rx bos (or "pushtag"
              "poptag"
              "pushmeta"
              "popmeta"
              "option"
              "include"
              "plugin"
              "transaction"
              "balance"
              "open"
              "close"
              "pad"
              "document"
              "note"
              "event"
              "price"
              "commodity"
              "query"
              "custom"
              ) eos)
  "`treesit-defun-type-regexp' for `beancount-ts-mode'.")

(defconst beancount-ts--simple-imenu-settings
  `(("Pushtag"      ,(rx bos "pushtag" eos)     treesit-node-named  beancount-ts--imenu-name-pushtag)
    ("Poptag"       ,(rx bos "poptag" eos)      treesit-node-named  beancount-ts--imenu-name-poptag)
    ("Pushmeta"     ,(rx bos "pushmeta" eos)    treesit-node-named  beancount-ts--imenu-name-pushmeta)
    ("Popmeta"      ,(rx bos "popmeta" eos)     treesit-node-named  beancount-ts--imenu-name-popmeta)
    ("Option"       ,(rx bos "option" eos)      treesit-node-named  beancount-ts--imenu-name-option)
    ("Include"      ,(rx bos "include" eos)     treesit-node-named  beancount-ts--imenu-name-include)
    ("Plugin"       ,(rx bos "plugin" eos)      treesit-node-named  beancount-ts--imenu-name-plugin)
    ("Transaction"  ,(rx bos "transaction" eos) treesit-node-named  beancount-ts--imenu-name-transaction)
    ("Balance"      ,(rx bos "balance" eos)     treesit-node-named  beancount-ts--imenu-name-balance)
    ("Open"         ,(rx bos "open" eos)        treesit-node-named  beancount-ts--imenu-name-open)
    ("Close"        ,(rx bos "close" eos)       treesit-node-named  beancount-ts--imenu-name-close)
    ("Pad"          ,(rx bos "pad" eos)         treesit-node-named  beancount-ts--imenu-name-pad)
    ("Document"     ,(rx bos "document" eos)    treesit-node-named  beancount-ts--imenu-name-document)
    ("Note"         ,(rx bos "note" eos)        treesit-node-named  beancount-ts--imenu-name-note)
    ("Event"        ,(rx bos "event" eos)       treesit-node-named  beancount-ts--imenu-name-event)
    ("Price"        ,(rx bos "price" eos)       treesit-node-named  beancount-ts--imenu-name-price)
    ("Commodity"    ,(rx bos "commodity" eos)   treesit-node-named  beancount-ts--imenu-name-commodity)
    ("Query"        ,(rx bos "query" eos)       treesit-node-named  beancount-ts--imenu-name-query)
    ("Custom"       ,(rx bos "custom" eos)      treesit-node-named  beancount-ts--imenu-name-custom))
  "`treesit-simple-imenu-settings' for `beancount-ts-mode'.")

;;;###autoload
(defun beancount-ts--outline-level ()
  "Function `outline-level' for `beancount-ts-mode'."
  (let ((m (match-string 0)))
    (if (eq (aref m 0) ?*)
        (1- (length m))   ; "* " -> 1, "** " -> 2
      (- (length m) 3)))) ; ";;; " -> 1, ";;;; " -> 2

;;;###autoload
(defun beancount-ts--imenu-name-pushtag (node)
  "Return the display name in imenu for NODE."
  (let* ((tag (treesit-node-child node 0 'named)))
    (treesit-node-text tag 'no-property)))

;;;###autoload
(defun beancount-ts--imenu-name-poptag (node)
  "Return the display name in imenu for NODE."
  (let* ((tag (treesit-node-child node 0 'named)))
    (treesit-node-text tag 'no-property)))

;;;###autoload
(defun beancount-ts--imenu-name-pushmeta (node)
  "Return the display name in imenu for NODE."
  (let* ((key-value (treesit-node-child node 0 'named)))
    (treesit-node-text key-value 'no-property)))

;;;###autoload
(defun beancount-ts--imenu-name-popmeta (node)
  "Return the display name in imenu for NODE."
  (let* ((key (treesit-node-child node 0 'named)))
    (treesit-node-text key 'no-property)))

;;;###autoload
(defun beancount-ts--imenu-name-option (node)
  "Return the display name in imenu for NODE."
  (let* ((key (treesit-node-child-by-field-name node "key"))
         (value (treesit-node-child-by-field-name node "value")))
    (format "%s %s"
            (treesit-node-text key 'no-property)
            (treesit-node-text value 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-include (node)
  "Return the display name in imenu for NODE."
  (let* ((str (treesit-node-child node 0 'named)))
    (format "%s" (treesit-node-text str 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-plugin (node)
  "Return the display name in imenu for NODE."
  (let* ((plugin-name (treesit-node-child node 0 'named))
         (plugin-config (treesit-node-child node 1 'named)))
    (if plugin-config
        (format "%s %s"
                (treesit-node-text plugin-name 'no-property)
                (treesit-node-text plugin-config 'no-property))
      (format "%s" (treesit-node-text plugin-name 'no-property)))))

;;;###autoload
(defun beancount-ts--imenu-name-transaction (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (txn (treesit-node-child-by-field-name node "txn"))
         (payee (treesit-node-child-by-field-name node "payee"))
         (narration (treesit-node-child-by-field-name node "narration"))
         (tags-links (treesit-node-child-by-field-name node "tags_links")))
    (string-join (seq-filter #'identity (list
                                         (treesit-node-text date 'no-property)
                                         (treesit-node-text txn 'no-property)
                                         (treesit-node-text payee 'no-property)
                                         (treesit-node-text narration 'no-property)
                                         (treesit-node-text tags-links 'no-property)
                                         )) " ")))

;;;###autoload
(defun beancount-ts--imenu-name-balance (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (account (treesit-node-child-by-field-name node "account"))
         (amount (treesit-node-child-by-field-name node "amount")))
    (format "%s %s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text account 'no-property)
            (treesit-node-text amount 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-open (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (account (treesit-node-child-by-field-name node "account")))
    (format "%s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text account 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-close (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (account (treesit-node-child-by-field-name node "account")))
    (format "%s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text account 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-pad (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (account (treesit-node-child-by-field-name node "account"))
         (from-account (treesit-node-child-by-field-name node "from_account")))
    (format "%s %s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text account 'no-property)
            (treesit-node-text from-account 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-document (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (account (treesit-node-child-by-field-name node "account"))
         (filename (treesit-node-child-by-field-name node "filename"))
         (tags-links (treesit-node-child-by-field-name node "tags_links")))
    (string-join (seq-filter #'identity (list
                                         (treesit-node-text date 'no-property)
                                         (treesit-node-text account 'no-property)
                                         (treesit-node-text filename 'no-property)
                                         (treesit-node-text tags-links 'no-property)
                                         )) " ")))
;;;###autoload
(defun beancount-ts--imenu-name-note (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (account (treesit-node-child-by-field-name node "account"))
         (note (treesit-node-child-by-field-name node "note")))
    (format "%s %s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text account 'no-property)
            (treesit-node-text note 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-event (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (type (treesit-node-child-by-field-name node "type"))
         (desc (treesit-node-child-by-field-name node "desc")))
    (format "%s %s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text type 'no-property)
            (treesit-node-text desc 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-price (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (currency (treesit-node-child-by-field-name node "currency"))
         (amount (treesit-node-child-by-field-name node "amount")))
    (format "%s %s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text currency 'no-property)
            (treesit-node-text amount 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-commodity (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (currency (treesit-node-child-by-field-name node "currency")))
    (format "%s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text currency 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-query (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (name (treesit-node-child-by-field-name node "name"))
         (query (treesit-node-child-by-field-name node "query")))
    (format "%s %s %s"
            (treesit-node-text date 'no-property)
            (treesit-node-text name 'no-property)
            (treesit-node-text query 'no-property))))

;;;###autoload
(defun beancount-ts--imenu-name-custom (node)
  "Return the display name in imenu for NODE."
  (let* ((date (treesit-node-child-by-field-name node "date"))
         (name (treesit-node-child-by-field-name node "name"))
         (custom-value-list (treesit-node-child-by-field-name node "custom_value_list")))
    (string-join (seq-filter #'identity (list
                                         (treesit-node-text date 'no-property)
                                         (treesit-node-text name 'no-property)
                                         (treesit-node-text custom-value-list 'no-property)
                                         )) " ")))

;;;###autoload
(define-derived-mode beancount-ts-mode prog-mode "Beancount"
  (when (treesit-ready-p 'beancount)
    ;; Initialize the parser.
    (setq-local treesit-primary-parser (treesit-parser-create 'beancount))

    ;; Font lock
    (setq-local treesit-font-lock-feature-list beancount-ts--font-lock-feature-list)
    (setq-local treesit-font-lock-settings beancount-ts--font-lock-settings)

    ;; Outline
    ;; `treesit-outline-predicate' does not support level.
    ;; So we set `outline-regexp' and `outline-level' instead.
    (setq-local treesit-outline-predicate nil)
    (setq-local outline-regexp beancount-ts--outline-regexp)
    (setq-local outline-level #'beancount-ts--outline-level)

    ;; Support `treesit-beginning-of-defun' and `treesit-end-of-defun'.
    (setq-local treesit-defun-type-regexp beancount-ts--defun-type-regexp)

    ;; `treesit-defun-name-function' is not supported.
    (setq-local treesit-defun-name-function nil)

    ;; Imenu
    (setq-local treesit-simple-imenu-settings beancount-ts--simple-imenu-settings)

    ;; TODO: support treesit-simple-indent-rules
    (treesit-major-mode-setup)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.beancount\\'" . beancount-ts-mode))

(provide 'beancount-ts-mode)
;;; beancount-ts-mode.el ends here
