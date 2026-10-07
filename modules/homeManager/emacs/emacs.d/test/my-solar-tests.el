;;; my-solar-tests.el --- my-solar-tests.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ert)
(require 'my-solar)

(ert-deftest my-solar-my/solar-term ()
  (should
   (equal
    (my/solar-term "立春" 2026)
    '((2 4 2026) "立春 04:01 (HKT)")))
  (should
   (equal
    (my/solar-term "冬至" 2026)
    '((12 22 2026) "冬至 04:49 (HKT)"))))

(provide 'my-solar-tests)
;;; my-solar-tests.el ends here
