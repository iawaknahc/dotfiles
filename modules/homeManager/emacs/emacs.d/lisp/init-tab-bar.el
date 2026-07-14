;;; -*- lexical-binding: t -*-

(defvar my-tab-bar-layout
  '(("mu4e"    . my-tab-bar-email-tab)
    ("*scratch*"  . my-tab-bar-scratch-tab)))

(defun my-tab-bar-email-tab ()
  (mu4e))

(defun my-tab-bar-scratch-tab ()
  (switch-to-buffer (get-buffer "*scratch*")))

(defun my-tab-bar-reset ()
  (interactive)
  (tab-bar-new-tab)
  (tab-bar-rename-tab "placeholder")
  ;; Close other tabs.
  (dolist (tab (tab-bar-tabs))
          (let ((name (alist-get 'name tab)))
            (unless (equal name "placeholder")
                    (tab-bar-close-tab-by-name name))))
  ;; Build the tabs.
  (dolist (spec my-tab-bar-layout)
          (tab-bar-new-tab)
          (tab-bar-rename-tab (car spec))
          (funcall (cdr spec)))
  ;; Close the placeholder
  (tab-bar-close-tab-by-name "placeholder")
  ;; Select the first tab.
  (tab-bar-select-tab-by-name (caar my-tab-bar-layout)))

(use-package
 emacs
 :ensure nil
 :custom
 ;; Show tab number.
 (tab-bar-tab-hints t)
 (tab-bar-new-tab-choice "*scratch*")
 :config
 (tab-bar-mode 1)
 ;; We cannot use :hook as it implies :defer, and emacs is not a package we can actually load.
 (add-hook 'after-init-hook #'my-tab-bar-reset)
 ;; Shadow M-1, M-2, and so on, which are bound to digit-argument by default.
 (dotimes (i 9)
   (let ((n (+ 1 i)))
     (keymap-global-set
      (format "M-%d" n)
      (lambda ()
              (interactive)
              (tab-bar-select-tab n))))))

(provide 'init-tab-bar)
