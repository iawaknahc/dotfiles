;;; init-display-buffer.el --- init-display-buffer.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; mu4e
(add-to-list
 'display-buffer-alist
 ;; When the command `mu4e' is invoked,
 `(,(rx string-start "*mu4e-main*" string-end) .
   ;; display the mu4e main buffer in a tab
   ((display-buffer-in-tab) .
    ;; named "mu4e", or create it if it does not exist yet
    ((tab-name . "mu4e")
     ;; in the selected frame.
     (reusable-frames . 'the-selected-frame)))))

;; grep-mode
(add-to-list
 'display-buffer-alist
 ;; When the command `grep' is invoked,
 `(,(rx string-start "*grep*" string-end) .
   ;; display the grep buffer in a side window
   ((display-buffer-in-side-window) .
    ;; at the bottom
    ((side . bottom)
     ;; spanning 1/3 of the frame height.
     (window-height . 0.33)))))

;; Eldoc
(add-to-list
 'display-buffer-alist
 ;; When the command `eldoc-doc-buffer' is invoked,
 `(,(rx string-start "*eldoc") . ; The buffer name keeps changing, thus we only match the prefix.
   ;; display the Eldoc buffer in a side window
   ((display-buffer-in-side-window) .
    ;; at the bottom
    ((side . bottom)
     ;; spanning 1/3 of the frame height.
     (window-height . 0.33)))))

;; Help
(add-to-list
 'display-buffer-alist
 ;; Whenever the help buffer is shown,
 `(,(rx string-start "*Help*" string-end) .
   ;; display it in a side window
   ((display-buffer-in-side-window) .
    ;; on the right
    ((side . right)
     ;; spanning 80 columns.
     (window-width . 80)))))

;; I have no idea how to configure *info* buffers yet.
;; Sometimes I am configuring Emacs, and I want to look up something.
;; In this use case, it seems better to have it displayed as side window, just like *Help*.
;; Sometimes I want to read manuals as if I am reading a book.
;; In this use case, I want it to be the only window in the frame.

(provide 'init-display-buffer)
;;; init-display-buffer.el ends here
