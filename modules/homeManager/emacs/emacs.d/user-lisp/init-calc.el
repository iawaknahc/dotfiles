;;; init-calc.el --- init-calc.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'xml)
(require 'iso8601)

(defvar calc-date-format)
(defvar math-additional-units)
(defvar math-units-table)
(defvar my/math-additional-units)
(declare-function math-convert-units "calc-units")
(declare-function math-format-date "calc-forms")
(declare-function math-format-number "calc")
(declare-function math-format-value "calc")
(declare-function math-read-expr "calc-ext")
(declare-function math-read-number "calc")
(declare-function math-round "calc-arith")
(declare-function my/call-command "my-lib")

(defconst my/currency-decimal-places
  '(;; Currencies with 0 decimal places.
    ("BIF" . 0)
    ("CLP" . 0)
    ("DJF" . 0)
    ("GNF" . 0)
    ("JPY" . 0)
    ("KMF" . 0)
    ("KRW" . 0)
    ("MGA" . 0)
    ("PYG" . 0)
    ("RWF" . 0)
    ("UGX" . 0)
    ("VND" . 0)
    ("VUV" . 0)
    ("XAF" . 0)
    ("XOF" . 0)
    ("XPF" . 0)
    ;; Currencies in special cases.
    ("ISK" . 0)
    ("HUF" . 0)
    ("TWD" . 0)
    ("UGX" . 0))
  "A alist of currency and their decimal place.

If a currency does not appear in this list,
then it is a 2-decimal place currency.")

(defun my/currency-get-decimal-places (currency)
  "Return the number of decimal places of CURRENCY.

CURRENCY is a string.
Return an integer indicating the decimal places of CURRENCY."
  (alist-get currency my/currency-decimal-places 2 nil #'string=))

(defun my/currency-convert (decimal source-currency target-currency)
  "Convert DECIMAL in SOURCE-CURRENCY to TARGET-CURRENCY.

Return a string representing the conversion.
All arguments are strings."
  (let* ((expr1 (math-read-expr (format "%s %s" decimal source-currency)))
         (expr2 (math-read-expr (format "%s" target-currency)))
         (expr3 (math-convert-units expr1 expr2)))
    ;; expr-3 is something like (* (float 203923241922 -8) (var JPY var-JPY)) or (var JPY var-JPY)
    (if (eq (nth 0 expr3) '*)
        (let* ((decimal-place (my/currency-get-decimal-places target-currency))
               (rounded (math-round (nth 1 expr3) decimal-place))
               (final-expr (list '* rounded (nth 2 expr3))))
          (math-format-value final-expr))
      (math-format-value (list '* 1 expr3)))))

(defun my/currency-convert-all (decimal source-currency)
  "Convert DECIMAL in SOURCE-CURRENCY to all known currencies.

Return a list of strings representing each conversion.
All arguments are strings."
  (seq-map (lambda (unit-specification)
             (let* ((target-currency (symbol-name (nth 0 unit-specification))))
               (my/currency-convert decimal source-currency target-currency)))
           my/math-additional-units))

(defun my/currency-syntactically-valid-currency-p (currency)
  "Return non-nil if CURRENCY is a string of exactly 3 uppercase characters."
  (and (stringp currency) (eql 3 (length currency)) (string= (upcase currency) currency)))

(defun my/currency-decimal-p (decimal)
  "Return non-nil if DECIMAL is a string and looks like a decimal number."
  (let* ((value (string-to-number decimal 10)))
    (or (floatp value)
        (and (integerp value)
             (or (not (zerop value))
                 (string= decimal "0")
                 (string= decimal "-0"))))))

(defun calcFunc-xirr (dates amounts)
  "Compute XIRR for DATES and AMOUNTS, using pyxirr.py which is backed by pyxirr.
DATES is a Calc vector containing dates.
AMOUNTS is a Calc vector containing numbers."
  (let* ((date-list (cdr dates))
         (amt-list  (cdr amounts))
         (calc-date-format '(YYYY "-" MM "-" DD))
         (date-vec (seq-into (seq-map #'math-format-date date-list) 'vector))
         (amt-vec (seq-into (seq-map #'math-format-number amt-list) 'vector))
         (input `(:dates ,date-vec :amounts ,amt-vec))
         (serialized-input (json-serialize input))
         (stdin (make-temp-file "calc-xirr")))
    (unwind-protect
        (progn
          (with-temp-file stdin
            (insert serialized-input))
          (math-read-number (my/call-command :stdin stdin :program "pyxirr-cli.py" :args '("xirr"))))
      (delete-file stdin))))

(defun calcFunc-xnpv (rate dates amounts)
  "Compute XNPV for RATE, DATES and AMOUNTS.
It uses pyxirr.py which is backed by pyxirr.
RATE is a Calc number, like (float 3 -2).
DATES is a Calc vector containing dates.
AMOUNTS is a Calc vector containing numbers."
  (let* ((date-list (cdr dates))
         (amt-list  (cdr amounts))
         (calc-date-format '(YYYY "-" MM "-" DD))
         (date-vec (seq-into (seq-map #'math-format-date date-list) 'vector))
         (amt-vec (seq-into (seq-map #'math-format-number amt-list) 'vector))
         (input `(:rate ,(math-format-number rate) :dates ,date-vec :amounts ,amt-vec))
         (serialized-input (json-serialize input))
         (stdin (make-temp-file "calc-xnpv")))
    (unwind-protect
        (progn
          (with-temp-file stdin
            (insert serialized-input))
          (math-read-number (my/call-command :stdin stdin :program "pyxirr-cli.py" :args '("xnpv"))))
      (delete-file stdin))))

(defconst my/calc-currency-file-path (expand-file-name "lisp/my-currency-units.el" user-emacs-directory)
  "The path to the file that defines currency units and the exchange rates.")

(defconst my/calc-currency-url-ecb "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
  "The daily exchange rate published by European Central Bank.

See the homepage https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html")

(defconst my/calc-currency-url-cbc "https://cpx.cbc.gov.tw/api/OpenData/FTDOpenData_Day"
  "每一營業日新臺幣對美元銀行間成交之收盤匯率.

顯名聲明
1. 提供機關：中央銀行 [日資料] [https://data.gov.tw/dataset/7232]
2. 此開放資料依政府資料開放授權條款 (Open Government Data License) 進行公眾釋出，
   使用者於遵守本條款各項規定之前提下，得利用之。
3. 政府資料開放授權條款：https://data.gov.tw/license")

(defun my/calc-currency-load ()
  "Load currency units."
  ;; Load the file if it exists,
  ;; so `my/calc-currency-written-at' is bound.
  (when (file-exists-p my/calc-currency-file-path)
    (load-file my/calc-currency-file-path))

  (let* ((now (current-time)))
    (cond
     ;; Write the file when it does not exist.
     ((not (file-exists-p my/calc-currency-file-path))
      (message "%s not found; writing it" my/calc-currency-file-path)
      (my/calc-currency-write-file))
     ;; Write the file when it is stale.
     ((boundp 'my/calc-currency-written-at)
      (let* ((written-at (encode-time (iso8601-parse my/calc-currency-written-at)))
             (diff (abs (float-time (time-subtract now written-at)))))
        (if (>= diff 86400)
            (progn
              (message "%s is stale; writing it" my/calc-currency-file-path)
              (my/calc-currency-write-file))
          (message "%s is up-to-date" my/calc-currency-file-path))))
     ;; Write the file anyway.
     (t
      (message "my/calc-currency-written-at is unbound; writing it")
      (my/calc-currency-write-file))))
  ;; Load the file.
  (load-file my/calc-currency-file-path)
  (setq math-additional-units my/math-additional-units)
  ;; Set it to nil to ask Calc to rebuild it.
  (setq math-units-table nil))

(defun my/calc-currency-write-file ()
  "Fetch exchange rates and write them to `my/calc-currency-file-path'.
The exchange rates are fetched from `my/calc-currency-url-ecb' and
`my/calc-currency-url-cbc'."
  (let* ((ecb (with-temp-buffer
                (url-insert-file-contents my/calc-currency-url-ecb)
                (let* ((root (xml-parse-region (point-min) (point-max)))
                       (cubes (xml-get-children (car (xml-get-children (car (xml-get-children (car root) 'Cube)) 'Cube)) 'Cube)))
                  `((EUR nil "*EUR")
                    ,@(cl-loop
                       for cube in cubes
                       for alist = (cadr cube)
                       for currency = (alist-get 'currency alist)
                       for rate = (alist-get 'rate alist)
                       collect (list (intern currency) (format "(1/%s) EUR" rate) currency nil (format "1 EUR = %s %s" rate currency)))))))
         (cbc (with-temp-buffer (url-insert-file-contents my/calc-currency-url-cbc)
                                (goto-char (point-min))
                                (let* ((array (json-parse-buffer :object-type 'plist :array-type 'array))
                                       (length (length array))
                                       (obj (aref array (1- length)))
                                       (rate-str (plist-get obj :NTD_USD)))
                                  (list (list 'TWD (format "(1/%s) USD" rate-str) "TWD" nil (format "1 USD = %s %s" rate-str "TWD"))))))
         (units (append ecb cbc nil))
         (terms `((defconst my/calc-currency-written-at ,(format-time-string "%FT%T%z" nil))
                  (defconst my/math-additional-units ',units))))
    (with-current-buffer (find-file-noselect my/calc-currency-file-path)
      (erase-buffer)
      (insert ";;; my-currency-units.el --- my-currency-units.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

")
      (cl-loop
       for term in terms
       do (insert "\n" (format "%S" term) "\n"))
      (save-buffer))))

(my/calc-currency-load)

(provide 'init-calc)
;;; init-calc.el ends here
