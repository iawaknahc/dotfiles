;;; init-display-buffer.el --- init-display-buffer.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Set the base action.
 ;; The intention is to avoid splitting windows.
 ;; Sometimes it is unavoidable because packages have hard-coded '(inhibit-same-window . t).
 ;; In that case, we use `display-buffer-in-direction'
 display-buffer-base-action
 `((
    ;; Reuse a window already showing the buffer.
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
 magit-commit-show-diff nil

 ;; *Org Agenda*
 ;;
 ;; I used to set `org-agenda-window-setup' to other-tab,
 ;; but that would always create new tabs in the following case:
 ;; 1. Hit c in the agenda to open calendar
 ;; 2. Hit c in calendar to open agenda. This will create a new tab.
 ;; 3. Hit c in the agenda to open calendar
 ;; 4. Hit c in calendar to open agenda. This will create yet another tab.
 ;;
 ;; The default value is reorganize-frame, which shows at most 2 windows.
 ;; Setting to current-window will cause Org to use `pop-to-buffer-same-window'.
 ;; See https://github.com/emacs-mirror/emacs/blob/emacs-31.1/lisp/org/org-agenda.el#L3928
 ;;
 ;; Before displaying *Org Agenda*, *Agenda Commands* is displayed.
 ;; That buffer is hard-coded to be displayed with `org-display-buffer-split'.
 ;; See https://github.com/emacs-mirror/emacs/blob/emacs-31.1/lisp/org/org-agenda.el#L3132
 ;; And `org-display-buffer-split' uses `display-buffer-in-direction' internally.
 ;; See https://github.com/emacs-mirror/emacs/blob/emacs-31.1/lisp/org/org-macs.el#L1846
 org-agenda-window-setup 'current-window)


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
       ,(rx string-start "*eldoc"))
   ;; display in a side window
   . ((display-buffer-in-side-window) .
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
  (when-let* ((selected-buf (window-buffer))
              (_ (with-current-buffer selected-buf (derived-mode-p 'help-mode)))
              (_ (with-current-buffer buffer-or-name (derived-mode-p 'Info-mode))))
    t))

;; Here is another concrete example of where an *info* buffer should go.
;; When I am in some project, and I need to look up the manual.
;; I want display the manual in a side window, rather than taking up the whole frame.
(defun my/display-buffer-alist-from-project-file-to-info-match (buffer-or-name &rest _args)
  "A `buffer-match-p' predicate function to check if BUFFER-OR-NAME is an *info* buffer and it is being displayed from a project file."
  (when-let* ((selected-buf (window-buffer))
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
