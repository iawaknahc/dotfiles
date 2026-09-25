;;; init-ghostel.el --- init-ghostel.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/text-property-search-backward (property &optional value predicate not-current)
  "Call (text-property-search-backward PROPERTY VALUE PREDICATE NOT-CURRENT) and return point."
  (when (text-property-search-backward property value predicate not-current)
    (point)))

(defun my/text-property-search-forward (property &optional value predicate not-current)
  "Call (text-property-search-forward PROPERTY VALUE PREDICATE NOT-CURRENT) and return point."
  (when (text-property-search-forward property value predicate not-current)
    (point)))

(defun my/ghostel-select-previous-output ()
  "Mark the previous output.

Point is placed at the beginning of the output."
  (interactive)
  (let* ((bounds
          (save-mark-and-excursion
            (cl-block loop
              (while t
                (if-let* ((start-from-here (my/text-property-search-backward 'ghostel-prompt nil nil t))
                          (input-prev-start (my/text-property-search-backward 'ghostel-input))
                          (input-prev-end (my/text-property-search-forward 'ghostel-input))
                          (output-prev-start (1+ input-prev-end))
                          (prompt-next-end (my/text-property-search-forward 'ghostel-prompt))
                          (prompt-next-start (my/text-property-search-backward 'ghostel-prompt))
                          (output-prev-end (1- prompt-next-start)))
                    (progn
                      (unless (eql output-prev-start prompt-next-start)
                        (cl-return-from loop (cons output-prev-start output-prev-end))))
                  (cl-return-from loop nil)))))))
    (if bounds
        (progn
          (goto-char (car bounds))
          (push-mark (cdr bounds) nil t))
      (error "No more previous output regions"))))

(defun my/ghostel-select-next-output ()
  "Mark the next output.

Point is placed at the end of the output."
  (interactive)
  (let* ((bounds
          (save-mark-and-excursion
            (cl-block loop
              (while t
                (if-let* ((start-from-here (my/text-property-search-forward 'ghostel-prompt nil nil t))
                          (input-prev-end (my/text-property-search-forward 'ghostel-input))
                          (output-prev-start (1+ input-prev-end))
                          (prompt-next-end (my/text-property-search-forward 'ghostel-prompt))
                          (prompt-next-start (my/text-property-search-backward 'ghostel-prompt))
                          (output-prev-end (1- prompt-next-start)))
                    (progn
                      (unless (eql output-prev-start prompt-next-start)
                        (cl-return-from loop (cons output-prev-start output-prev-end))))
                  (cl-return-from loop nil)))))))
    (if bounds
        (progn
          (goto-char (cdr bounds))
          (push-mark (car bounds) nil t))
      (error "No more next output regions"))))

(with-eval-after-load 'ghostel
  (keymap-set ghostel-mode-map "C-c <up>" #'my/ghostel-select-previous-output)
  (keymap-set ghostel-mode-map "C-c <down>" #'my/ghostel-select-next-output))

(defvar-keymap my/ghostel-output-repeat-map
  :doc "Repeat map for `my/ghostel-select-next-output' and `my/ghostel-select-previous-output'."
  :repeat t
  "<up>"   #'my/ghostel-select-previous-output
  "<down>" #'my/ghostel-select-next-output)

(provide 'init-ghostel)
;;; init-ghostel.el ends here
