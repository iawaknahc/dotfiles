;;; init-tab-bar.el --- init-tab-bar.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Show tab number.
 tab-bar-tab-hints t
 ;; The default is '(tab-bar-format-history
 ;;                  tab-bar-format-tabs
 ;;                  tab-bar-separator
 ;;                  tab-bar-format-add-tab)
 ;; So it means we want to get rid of the history buttons, and group the tabs.
 tab-bar-format
 '(
   tab-bar-format-tabs-groups
   tab-bar-separator
   tab-bar-format-add-tab))

(tab-bar-mode 1)
;; `tab-bar-history-mode' is `winner-mode'.
(tab-bar-history-mode 1)

(defun my/tab-bar-kill-buffer-hook ()
  "When a buffer is about to be killed, and the following conditions hold:

1. `tab-tab-mode' is enabled.
2. The buffer is in the current tab.
3. The current tab has only one window showing the buffer.

Then the tab will be closed together.

The implementation does not loop through all tabs
because non-current tabs have no window objects.
It is required to actually switch to the tabs in order to
make the windows appear.
That may cause flickering."
  (if-let* ((_ (bound-and-true-p tab-bar-mode))
            (buf (current-buffer))
            (win (get-buffer-window buf))
            (tabs (funcall tab-bar-tabs-function))
            (tab (tab-bar--current-tab-find tabs))
            (tab-index (tab-bar--tab-index tab tabs))
            (tab-number (1+ tab-index))
            (_ (with-selected-window win (one-window-p 'exclude-mini-buffer))))
      (tab-bar-close-tab tab-number)))
(add-hook 'kill-buffer-hook #'my/tab-bar-kill-buffer-hook)

(defun my/consult-tabs ()
  "Switch to a tab using `consult--read'.
The candidates are from `tab-bar-tabs-function'.

The difference between this command and `tab-bar-switch-to-tab' are
1. `tab-bar-switch-to-tab' sorts the tabs by recency,
    while this command sorts by tab-number.
2. `tab-bar-switch-to-tab' excludes the current tab,
    while this command includes and make it the default selected candidate.
3. The candidate string includes the tab number, the tab group,
   and the tab number.
   So we need not use & to search in the annotation.

Finally, `tab-bar-select-tab' is used to select tab by tab number.
`tab-bar-switch-to-tab' is not used because tabs can have duplicated names."
  (interactive)
  (require 'tab-bar)
  (require 'consult)
  (let* ((tabs (funcall tab-bar-tabs-function))
         (candidates
          (cl-loop for tab in tabs
                   for tab-number from 1
                   collect
                   (let* ((current-tab-p (eq (car tab) 'current-tab))
                          (tab-name (alist-get 'name tab))
                          (tab-group (alist-get 'group tab)))
                     (propertize
                      (format "%s %d [%s] %s"
                              (if current-tab-p "*" " ")
                              tab-number
                              (or tab-group "NO-GROUP")
                              tab-name)
                      'tab-name tab-name
                      'tab-group tab-group
                      'tab-number tab-number
                      'current-tab-p current-tab-p)))))
    (tab-bar-select-tab
     (consult--read
      candidates
      :prompt "Switch to tab: "
      :require-match t
      :sort nil
      :default (cl-find-if
                (lambda (c) (get-text-property 0 'current-tab-p c))
                candidates)
      ;; If we use 'tab as the category, the :annotate function will not be called.
      ;; I guess this is due to `marginalia-annotate-tab' is registered as a annotation function of category 'tab.
      ;; Thus, we use a custom category here, and specify an annotation function.
      ;; The annotation function just delegate to `marginalia-annotate-tab'.
      :category 'my/tab
      :annotate (lambda (c)
                  (let* ((tab-name (get-text-property 0 'tab-name c)))
                    (marginalia-annotate-tab tab-name)))
      :lookup (apply-partially #'consult--lookup-prop 'tab-number)
      ;; Previewing with :state does not work using `tab-bar-select-tab' does not work.
      ;; Let's give up preview here.
      ))))
(keymap-global-set "C-x t RET" #'my/consult-tabs)

(provide 'init-tab-bar)
;;; init-tab-bar.el ends here
