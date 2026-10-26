;;; init-eglot.el --- init-eglot.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(defun my/add-before-save-hook-for-eglot-format-buffer ()
  "Invoke `eglot-format-buffer' in `before-save-hook' in a buffer-local fashion."
  (add-hook 'before-save-hook #'eglot-format-buffer nil t))

;; `eglot' can only be run in major modes that have a configured language server.
;; Therefore, we do not use `prog-mode-hook'.
(dolist (hook '(go-ts-mode-hook
                python-mode-hook
                python-ts-mode-hook
                typescript-ts-mode-hook
                fish-mode-hook
                nushell-ts-mode-hook
                nix-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

(defun my/eglot-beancount-ts-mode-hook ()
  "Disable imenu."
  (setq-local eglot-stay-out-of '(imenu))
  (eglot-ensure))
(add-hook 'beancount-ts-mode-hook #'my/eglot-beancount-ts-mode-hook)

;; For these major modes, ask the language server to format the buffer.
(dolist (hook '(go-ts-mode-hook fish-mode-hook nix-ts-mode-hook))
  (add-hook hook #'my/add-before-save-hook-for-eglot-format-buffer))

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
 eglot-code-action-indications '(margin))

(defun my/eglot-managed-mode-hook ()
  "Disable inlay hints and semantic tokens by default."
  (eglot-inlay-hints-mode -1)
  (eglot-semantic-tokens-mode -1)
  ;; It was used to enable inlay hint mode for in beancount-mode,
  ;; but the inlay hints may interfere with editing.
  )

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

(defconst my/eglot-root-markers
  '(((lua-mode lua-ts-mode) . (".emmyrc.json")))
  "Alist of (MODES . MARKERS).")

(defun my/eglot-project-root-marker (dir)
  "Search upward from DIR to find a directory with a root marker.

The root markers are defined in `my/eglot-root-markers'."
  (when-let* (
              ;; `eglot-lsp-context' is bound to non-nil when `project-current' is invoked by eglot
              ;; to find a suitable root for launching a LSP server.
              (_ (bound-and-true-p eglot-lsp-context))
              ;; See if the current major mode has any markers defined.
              (markers (cdr-safe (seq-find
                                  (lambda (entry)
                                    (derived-mode-p (car entry)))
                                  my/eglot-root-markers)))
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

(with-eval-after-load 'eglot
  (setf (alist-get 'beancount-ts-mode eglot-server-programs) #'my/eglot-beancount-language-server-contact)
  (setf (alist-get 'go-ts-mode eglot-server-programs) '("rass" "go"))
  (setf (alist-get '(python-mode python-ts-mode) eglot-server-programs) '("rass" "python"))
  (setf (alist-get '(lua-mode lua-ts-mode) eglot-server-programs) '("emmylua_ls"))
  ;; tsgo supports pull diagnostics only.
  ;; Eglot has support for pull diagnostics since 1.20
  ;; See https://github.com/emacs-mirror/emacs/blob/emacs-31.0.91/etc/EGLOT-NEWS#L137
  ;;
  ;; When rass is used, it becomes broken.
  ;; I guess rass needs to support pull diagnostics as well.
  ;; (setf (alist-get 'typescript-ts-mode eglot-server-programs) '("rass" "typescript"))
  (setf (alist-get 'typescript-ts-mode eglot-server-programs) '("tsgo" "--lsp" "--stdio"))
  (setf (alist-get 'fish-mode eglot-server-programs) '("rass" "fish"))
  (setf (alist-get 'nushell-ts-mode eglot-server-programs) '("rass" "nushell"))
  (setf (alist-get 'nix-ts-mode eglot-server-programs) '("rass" "nix"))

  (add-hook 'eglot-managed-mode-hook #'my/eglot-managed-mode-hook))

(with-eval-after-load 'project
  (add-hook 'project-find-functions #'my/eglot-project-root-marker))

(provide 'init-eglot)
;;; init-eglot.el ends here
