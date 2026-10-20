;;; my-rng.el --- my-rng.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'cl-lib)

;;;###autoload
(defun my/random-bytes (n)
  "Return a vector containing N random bytes from /dev/random.

N must be greater than 0."
  (cl-assert (and (integerp n) (> n 0)))
  (with-temp-buffer
    ;; Treat the bytes in the buffer as binary.
    (set-buffer-multibyte nil)
    (let* ((coding-system-for-read 'binary)
           (status-or-signal-string (call-process "head" "/dev/random" '(t nil) nil "-c" (format "%d" n))))
      (unless (and (eql status-or-signal-string 0) (eql (buffer-size) n))
        (error "Failed to read %d bytes from /dev/random (status %S)" n status-or-signal-string))
      (vconcat (buffer-string)))))

;;;###autoload
(defun my/uuid4-bytes ()
  "Generate a UUID4 as 16 bytes."
  (let* ((bytes (my/random-bytes (/ 128 8))))
    ;; Set bit 48 to bit 51 to 0100.
    (aset bytes 6 (logior #b01000000 (logand (aref bytes 6) #b00001111)))
    ;; Set bit 64 and bit 65 to 10.
    (aset bytes 8 (logior #b10000000 (logand (aref bytes 8) #b00111111)))
    bytes))

;;;###autoload
(defun my/uuid-to-string (uuid-bytes &optional upcase)
  "Return the string representation of UUID-BYTES.

If UPCASE is non-nil, the return value is in upcase.
Otherwise in downcase."
  (cl-assert (eql (length uuid-bytes) 16))
  (string-join (seq-map-indexed (lambda (byte index)
                                  (cl-assert (and (natnump byte) (<= byte 255)))
                                  (format (concat (pcase index ((or 4 6 8 10) "-") (_ ""))
                                                  "%02"
                                                  (if upcase "X" "x"))
                                          byte))
                                uuid-bytes)
               ""))

(provide 'my-rng)
;;; my-rng.el ends here
