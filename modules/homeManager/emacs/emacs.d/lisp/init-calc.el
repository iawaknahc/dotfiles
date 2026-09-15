;;; init-calc.el --- init-calc.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'xml)
(require 'iso8601)

(defun calcFunc-xirr (dates amounts)
  "Compute XIRR for DATES and AMOUNTS, using pyxirr.py which is backed by pyxirr.
DATES is a Calc vector containing dates.
AMOUNTS is a Calc vector containing numbers."
  (require 'my-lib)
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
  "Compute XNPV for RATE, DATES and AMOUNTS, using pyxirr.py which is backed by pyxirr.
RATE is a Calc number, like (float 3 -2).
DATES is a Calc vector containing dates.
AMOUNTS is a Calc vector containing numbers."
  (require 'my-lib)
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
2. 此開放資料依政府資料開放授權條款 (Open Government Data License) 進行公眾釋出，使用者於遵守本條款各項規定之前提下，得利用之。
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
  "Fetch `my/calc-currency-url-ecb' and `my/calc-currency-url-cbc' and then write `my/calc-currency-file-path'."
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
         (terms `((defconst my/calc-currency-written-at ,(format-time-string "%FT%T%z"))
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
