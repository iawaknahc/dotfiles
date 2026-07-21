;;; init-lsp-mode.el --- init-lsp-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; This was the configuration I used when I tried to integrate lsp-mode.
;; I encountered many problems.
;;
;; The first problem is that nix-nil and nixd are not configured to run together by default.
;; nix-nil has a priority of 0 so it is selected.
;; I need to change the slot `add-on?` of nixd to make it run along with nix-nil.
;;
;; The second problem is that nixd exits immediately when I open a Nix file.
;; I need to set `lsp-log-io` to t to debug myself.
;; From the stderr of nixd, I discovered that lsp-mode will send semantic token requests,
;; even before the workspace configuration is sent to the server.
;; I turned off `lsp-semantic-tokens-enable` and the problem was resolved.
;; `lsp-semantic-tokens-enable` is nil by default so I guess it is not a stable feature.
;;
;; Now that I get both nix-nil and nixd running together.
;; When I save a Nix file, nix-nil exits immediately.
;; I checked the stderr of nix-nil and found that it received an unexpected textDocument/didSave notification.
;; I turned off `lsp-before-save-edits`, `lsp-fix-all-on-save`, and `lsp-format-buffer-on-save`,
;; none of these solve the issue.
;;
;; The next step for me is to try Eglot with rassumfrassum.
;; The following code are not actually used.
;; They are kept in case I want to use lsp-mode in the future.
;;
;;; Code:

(setq
 lsp-auto-configure t
 lsp-enable-symbol-highlighting nil
 lsp-enable-folding nil
 lsp-enable-on-type-formatting nil
 lsp-enable-suggest-server-download nil
 lsp-diagnostics-provider 'flycheck
 lsp-headerline-breadcrumb-enable nil
 lsp-modeline-diagnostics-scope 'workspace

 ;; It is important to turn this off.
 ;; As of lsp-mode 10.0.0, when this is on,
 ;; it is observed that lsp-mode will send many semantic token requests before
 ;; the configuration request is sent.
 ;; It was observed that if nix-nil and nixd are running together,
 ;; nixd will exit immediately.
 lsp-semantic-tokens-enable nil

 lsp-enable-indentation nil

 ;; Even I turned all these on-save actions off,
 ;; lsp-mode still send textDocument/didSave to nil,
 ;; causing it to crash.
 lsp-before-save-edits nil
 lsp-fix-all-on-save nil
 lsp-format-buffer-on-save nil

 lsp-nix-nil-formatter ["nixfmt"]
 )
(require 'init-lsp-mode-nixd)

(defun my/lsp-mode ()
  "Call `lsp' unless it is `emacs-lisp-mode'."
  (unless (eq major-mode 'emacs-lisp-mode)
    (lsp)))

(add-hook 'prog-mode-hook #'my/lsp-mode)
;; (add-hook 'text-mode-hook #'my/lsp-mode)

(defun my/lsp-set-add-on (client-id)
  "Set add-on? to t for CLIENT-ID in `lsp-clients'."
  (let* ((client (gethash client-id lsp-clients)))
    (aset client (cl-struct-slot-offset 'lsp--client 'add-on?) t)))

(with-eval-after-load 'lsp-mode
  (with-eval-after-load 'lsp-nix
    (my/lsp-set-add-on 'nixd-lsp)))

(provide 'init-lsp-mode)
;;; init-lsp-mode.el ends here
