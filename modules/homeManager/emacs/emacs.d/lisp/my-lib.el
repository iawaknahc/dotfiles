;;; my-lib.el --- my-lib.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(cl-defun my/call-process (&key
                           (working-directory default-directory)
                           stdin
                           stdout
                           stderr
                           program
                           args)
  "A wrapper of `call-process' with a nicer keyword argument only interface.

WORKING-DIRECTORY is `default-directory' by default.
STDIN is nil by default.
STDOUT is nil by default.
STDERR is nil by default.
PROGRAM is nil by default.
ARGS is nil by default."
  (let ((default-directory working-directory))
    (apply #'call-process program stdin (list stdout stderr) nil args)))

(cl-defun my/call-command (&key
                           (working-directory default-directory)
                           stdin
                           program
                           args)
  "Call external command PROGRAM with ARGS.
Capture the stdout and return it as string.

If the stdout ends with a newline, it is removed.
This behavior is like Shell process substitution.

The stderr is always appended to *Messages*.

WORKING-DIRECTORY is `default-directory' by default.
STDIN is nil by default."
  (let* ((stdout (generate-new-buffer "*stdout*"))
         (stderr-file (make-temp-file "call-process-stderr-")))
    (unwind-protect
        (progn
          (my/call-process :working-directory working-directory :stdin stdin :stdout stdout :stderr stderr-file :program program :args args)
          (with-current-buffer (get-buffer-create "*Messages*")
            (let ((inhibit-read-only t))
              (goto-char (point-max))
              (insert-file-contents stderr-file)))
          (with-current-buffer stdout
            (buffer-substring-no-properties
             (point-min)
             (if (eq (char-before (point-max)) ?\n)
                 (1- (point-max))
               (point-max)))))
      (kill-buffer stdout)
      (delete-file stderr-file))))

(provide 'my-lib)
;;; my-lib.el ends here
