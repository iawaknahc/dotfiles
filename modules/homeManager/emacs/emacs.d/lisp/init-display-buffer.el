;;; init-display-buffer.el --- init-display-buffer.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; *scratch*
(add-to-list
 'display-buffer-alist
 ;; When the *scratch* buffer is displayed,
 `(,(rx string-start "*scratch*" string-end) .
   ;; display it in a tab
   ((display-buffer-in-tab) .
    ;; named "*scratch*"
    ((tab-name . "*scratch*")
     ;; in the tab group "EMACS"
     (tab-group . "EMACS")
     ;; in the selected frame.
     (reusable-frames . the-selected-frame)))))
(defun my/window-setup-hook-display-buffer-scratch ()
  "Make our `display-buffer' configuration on *scratch* applied once."
  (if-let* ((messages-buf (get-buffer "*Messages*"))
            ;; Ungrouped tab 1 contains a single window displaying *Messages*
            (_ (display-buffer messages-buf `((display-buffer-same-window . ()))))
            (scratch-buf (get-buffer "*scratch*"))
            ;; Grouped tab 2 contains a single window displaying *scratch*
            (_ (display-buffer scratch-buf)))
      ;; Close tab 1, thus tab 2 becomes tab 1.
      (tab-bar-close-tab 1)))
;; Ensure the tab group is created.
(add-hook 'window-setup-hook #'my/window-setup-hook-display-buffer-scratch)

;; mu4e
(add-to-list
 'display-buffer-alist
 ;; When the command `mu4e' is invoked,
 `(,(rx string-start "*mu4e-main*" string-end) .
   ;; display the mu4e main buffer in a tab
   ((display-buffer-in-tab) .
    ;; named "mu4e"
    ((tab-name . "mu4e")
     ;; in the tab group "EMAIL"
     (tab-group . "EMAIL")
     ;; in the selected frame.
     (reusable-frames . the-selected-frame)))))

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

;; Project file
(defun my/display-buffer-alist-project-file-match-project-file (buffer-or-name &rest _args)
  "A `buffer-match-p' predicate function to check if BUFFER-OR-NAME belongs to a project."
  (with-current-buffer buffer-or-name
    ;; It is a project file if all of the following holds:
    ;; 1. `project-current' returns non-nil such that the buffer belongs to some project.
    ;; 2. `buffer-file-name' returns non-nil so that the buffer is really backed by a file.
    ;;     This condition is consistently with our advice on `project-buffers'.
    (and (project-current) (buffer-file-name))))

(defun my/display-buffer-alist-project-file-tab-name (buffer-or-name alist)
  "The tab-name function to select a tab name for BUFFER-OR-NAME AND ALIST.

In particular, if the current tab is in the same tab group,
then the current tab is used to display the buffer.
Otherwise, return nil to signify we want to create a tab without explicit name."
  (or (if-let* ((current-tab (tab-bar--current-tab-find))
                (current-tab-name (alist-get 'name current-tab))
                (current-group (alist-get 'group current-tab))
                (this-group (my/display-buffer-alist-project-file-tab-group buffer-or-name alist))
                (_ (string= current-group this-group)))
          current-tab-name)
      ;; Return nil to signify we want to create a new tab without explicit name.
      nil))

(defun my/display-buffer-alist-project-file-tab-group (buffer-or-name _alist)
  "The `tab-group' function to derive `tab-group' from BUFFER-OR-NAME."
  (with-current-buffer buffer-or-name
    (or (if-let* ((proj (project-current))
                  (proj-name (project-name proj))
                  (t-group (format "PROJECT:%s" proj-name)))
            t-group
          )
        ;; This is actually unreachable.
        "ERROR")))

(add-to-list
 'display-buffer-alist
 ;; When a project file is displayed,
 `(,(function my/display-buffer-alist-project-file-match-project-file) .
   ;; display it in a tab
   ((display-buffer-in-tab) .
    ;; in which the current tab is preferred
    ((tab-name . ,(function my/display-buffer-alist-project-file-tab-name))
     ;; with the project being the tab group
     (tab-group . ,(function my/display-buffer-alist-project-file-tab-group))
     ;; in the selected frame.
     (reusable-frames . the-selected-frame)))))

;; I have no idea how to configure *info* buffers yet.
;; Sometimes I am configuring Emacs, and I want to look up something.
;; In this use case, it seems better to have it displayed as side window, just like *Help*.
;; Sometimes I want to read manuals as if I am reading a book.
;; In this use case, I want it to be the only window in the frame.

(provide 'init-display-buffer)
;;; init-display-buffer.el ends here
