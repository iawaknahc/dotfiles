;;; init-calc.el --- init-calc.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

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

(provide 'init-calc)
;;; init-calc.el ends here
