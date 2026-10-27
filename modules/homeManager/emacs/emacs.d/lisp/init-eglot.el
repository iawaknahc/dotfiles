;;; init-eglot.el --- init-eglot.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; In beancount file, beancount-language-server reported aligned balance as inlay hint.
;; The default face has :height 0.8 which breaks the alignment.
;; Therefore, we reset the face to have unspecified :height.
(custom-set-faces
 '(eglot-inlay-hint-face ((t (:inherit shadow)))))

(setq
 ;; The default is a light bulb emoji, which causes
 ;; the text to flicker when point lands on the line.
 ;; So we set it to a printable ASCII character.
 eglot-code-action-indicator "?"
 ;; The default is '(eldoc-hint margin)
 ;; We already have the indicator in the margin,
 ;; the indicator of eldoc is just redundant and takes up precious space.
 eglot-code-action-indications '(margin)
 eglot-documentation-renderer #'markdown-ts-view-mode)

(defun my/eglot-managed-mode-hook ()
  "Disable inlay hints and semantic tokens by default."
  (eglot-inlay-hints-mode -1)
  (eglot-semantic-tokens-mode -1)
  ;; It was used to enable inlay hint mode for in beancount-mode,
  ;; but the inlay hints may interfere with editing.
  )
(with-eval-after-load 'eglot
  (add-hook 'eglot-managed-mode-hook #'my/eglot-managed-mode-hook))

(defun my/eglot-beancount-language-server-contact (_interactive project)
  "Return a configuration for PROJECT."
  (let* (init-options)
    (when-let* ((_ project)
                (proj-root (project-root project))
                (main (expand-file-name "./main.beancount" proj-root))
                (_ (file-readable-p main)))
      (setq init-options `(:initializationOptions (:journal_file ,main))))
    (message "init-options: %S" init-options)
    `("rass" "beancount" ,@init-options)))

(defconst my/eglot-configurations
  '(
    (:major-modes
     (lua-ts-mode)
     :contact ("emmylua_ls")
     :root-markers (".emmyrc.json"))
    (:major-modes
     (beancount-ts-mode)
     :contact my/eglot-beancount-language-server-contact
     :eglot-stay-out-of (imenu))
    (:major-modes
     (go-ts-mode)
     :contact ("rass" "go")
     :format-buffer-in-before-save-hook t)
    (:major-modes
     (python-ts-mode)
     :contact ("rass" "python"))
    (:major-modes
     (fish-mode)
     :contact ("rass" "fish")
     :format-buffer-in-before-save-hook t)
    (:major-modes
     (nushell-ts-mode)
     :contact ("rass" "nushell"))
    (:major-modes
     (typescript-ts-mode js-ts-mode)
     ;; tsc supports pull diagnostics only.
     ;; Eglot has support for pull diagnostics since 1.20
     ;; See https://github.com/emacs-mirror/emacs/blob/emacs-31.0.91/etc/EGLOT-NEWS#L137
     ;;
     ;; When rass is used, it becomes broken.
     ;; I guess rass needs to support pull diagnostics as well.
     :contact ("tsc" "--lsp" "--stdio"))
    (:major-modes
     (html-ts-mode mhtml-ts-mode)
     :contact ("vscode-html-language-server" "--stdio"))
    (:major-modes
     (nix-ts-mode)
     :contact ("rass" "nix")
     :format-buffer-in-before-save-hook t))
  "A list of configurations.

Each configuration is a plist with the following properties:
- :major-modes a list of major modes.
- :contact See `eglot-server-programs'.
- :root-markers a list of root markers.
- :eglot-stay-out-of `eglot-stay-out-of' to be set as buffer-local variable.
- :format-buffer-in-before-save-hook whether to run `eglot-format-buffer' in `before-save-hook'.

:major-modes and :contact are required, others are optional.")

(setq eglot-server-programs nil)
(dolist (plist my/eglot-configurations)
  (let* ((major-modes (plist-get plist :major-modes))
         (contact (plist-get plist :contact))
         (stay-out-of (plist-get plist :eglot-stay-out-of))
         (format-buffer-in-before-save-hook (plist-get plist :format-buffer-in-before-save-hook)))

    ;; Teach eglot how to launch the LSP server.
    (push (cons major-modes contact) eglot-server-programs)

    (dolist (major-mode major-modes)
      (let* ((major-mode-hook (intern (format "%S-hook" major-mode))))
        (add-hook major-mode-hook (lambda ()
                                    ;; Respect :eglot-stay-out-of
                                    (when stay-out-of
                                      (setq-local eglot-stay-out-of stay-out-of))
                                    ;; Respect :format-buffer-in-before-save-hook
                                    (when format-buffer-in-before-save-hook
                                      (add-hook 'before-save-hook #'eglot-format-buffer nil t))
                                    ;; Auto-start eglot.
                                    (eglot-ensure)))))))

(defun my/eglot-project-root-marker (dir)
  "Search upward from DIR to find a directory with a root marker.

The root markers are defined in `my/eglot-configurations'."
  (when-let* (
              ;; `eglot-lsp-context' is bound to non-nil when `project-current' is invoked by eglot
              ;; to find a suitable root for launching a LSP server.
              (_ (bound-and-true-p eglot-lsp-context))
              ;; See if the current major mode has any markers defined.
              (markers (plist-get (seq-find
                                   (lambda (plist)
                                     (let* ((major-modes (plist-get plist :major-modes)))
                                       (derived-mode-p major-modes)))
                                   my/eglot-configurations)
                                  :root-markers))
              ;; Search upward from DIR to find a directory containing one of the markers.
              (root (locate-dominating-file
                     dir
                     (lambda (dir)
                       (seq-some (lambda (marker)
                                   (file-readable-p (expand-file-name marker dir)))
                                 markers)))))
    ;; transient is a special kind of project instance.
    ;; See `project-current' for details.
    (cons 'transient root)))
(with-eval-after-load 'project
  (add-hook 'project-find-functions #'my/eglot-project-root-marker))

(provide 'init-eglot)
;;; init-eglot.el ends here
