;;; init-display-buffer.el --- init-display-buffer.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Set the base action.
;; The intention is to avoid splitting windows.
;; Sometimes it is unavoidable because packages have hard-coded '(inhibit-same-window . t).
;; In that case, we use `display-buffer-in-direction'
(setq
 display-buffer-base-action
 ;; Reuse a window already showing the buffer.
 `((
    display-buffer-reuse-window
    ;; Reuse a window whose major mode is the same as that of the buffer about to being displayed.
    display-buffer-reuse-mode-window
    ;; Reuse the selected window
    display-buffer-same-window
    ;; Reuse a window which is not dedicated.
    display-buffer-use-some-window
    ;; As a last resort, make a new window on the right
    display-buffer-in-direction) .
    ;; in the selected frame
    ((reusable-frames . the-selected-frame)
     ;; Allow reusing the selected window
     (inhibit-same-window . nil)
     ;; Use the most recently used window
     (some-window . mru)
     ;; Make a window on the right
     (direction . right)
     ;; relative to `window-main-window'.
     (window . main)))
 ;; By default, `magit-commit-show-diff' is non-nil.
 ;; When commit, Magit first shows the commit buffer, followed by the diff buffer.
 ;; But `magit-commit-diff-inhibit-same-window' is nil by default, thus,
 ;; The diff buffer will hide the commit buffer, making the commit flow looks broken.
 ;; When we are committing, we expect the UI to be ready to accept commit message,
 ;; not viewing the diff.
 ;; On the other hand, we have enable the flag --verbose by default in git config.
 ;; The diff is already included in the commit buffer.
 magit-commit-show-diff nil)

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

;; Buffers that I prefer displaying in the bottom side window.
(add-to-list
 'display-buffer-alist
 `((or (derived-mode . compilation-mode)
       (derived-mode . occur-mode)
       (derived-mode . flymake-diagnostics-buffer-mode)
       (derived-mode . flymake-project-diagnostics-mode)
       (derived-mode . xref--xref-buffer-mode)
       (derived-mode . xref-edit-mode)
       (derived-mode . debugger-mode)
       (derived-mode . apropos-mode)
       ;; The *Warnings* is in special-mode, so just match by name.
       ,(rx string-start "*Warnings*" string-end)
       ;; The Eldoc buffer is in special-mode.
       ;; The buffer name keeps changing, thus we only match the prefix.
       ,(rx string-start "*eldoc")) .
       ;; display in a side window
       ((display-buffer-in-side-window) .
        ;; at the bottom
        ((side . bottom)
         ;; spanning 1/3 of the frame height.
         (window-height . 0.33)))))

;; Buffers that I prefer displaying in the right side window.

;; Here is a concrete example of I know for sure where an *info* buffer should go.
;; Docstrings include reference to various Info manuals.
;; When I follow the reference,
;; I expect the manual to be displayed in the same window.
;; We cannot use `display-buffer-same-window' because
;; the *Help* buffer is displayed in a dedicated side window.
(defun my/display-buffer-alist-from-help-to-info-match (buffer-or-name &rest _args)
  "A `buffer-match-p' predicate function to check if BUFFER-OR-NAME is an *info* buffer and it is being displayed from a *Help* buffer."
  (if-let* ((selected-buf (window-buffer))
            (_ (with-current-buffer selected-buf (derived-mode-p 'help-mode)))
            (_ (with-current-buffer buffer-or-name (derived-mode-p 'Info-mode))))
      t))

;; Here is another concrete example of where an *info* buffer should go.
;; When I am in some project, and I need to look up the manual.
;; I want display the manual in a side window, rather than taking up the whole frame.
(defun my/display-buffer-alist-from-project-file-to-info-match (buffer-or-name &rest _args)
  "A `buffer-match-p' predicate function to check if BUFFER-OR-NAME is an *info* buffer and it is being displayed from a project file."
  (if-let* ((selected-buf (window-buffer))
            (current-proj (with-current-buffer selected-buf (project-current)))
            (_ (with-current-buffer buffer-or-name (derived-mode-p 'Info-mode))))
      t))

(add-to-list
 'display-buffer-alist
 `((or (derived-mode . help-mode)
       ;; The buffer displayed by `org-capture'.
       ,(rx string-start "*Org Select*" string-end)
       ,(function my/display-buffer-alist-from-help-to-info-match)
       ,(function my/display-buffer-alist-from-project-file-to-info-match)) .
       ;; display in a side window
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

(defun my/maximize-window (&optional window)
  "Like `maximize-window', but ignore is set to `safe'.
If WINDOW is nil, it is selected window."
  (interactive)
  (setq window (window-normalize-window window))
  (let* ((horizontal nil)
         (vertical t)
         (ignore 'safe)
         (trail nil)
         (no-up nil)
         (no-down nil)
         (horizontal-max-delta (window-max-delta window horizontal ignore trail no-up no-down window-resize-pixelwise))
         (vertical-max-delta (window-max-delta window vertical ignore trail no-up no-down window-resize-pixelwise)))
    (window-resize window horizontal-max-delta horizontal ignore window-resize-pixelwise)
    (window-resize window vertical-max-delta vertical ignore window-resize-pixelwise)))
;; It is expected to use \\[C-c <left>] and \\[C-c <right>] to restore.
;; The above key bindings are the defaults of `winner-mode' and `tab-bar-history-mode'.
(keymap-global-set "C-x w m" #'my/maximize-window)

(provide 'init-display-buffer)
;;; init-display-buffer.el ends here
