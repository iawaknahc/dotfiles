;;; my-ecard.el --- my-ecard.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'calendar)
(require 'cl-lib)
(require 'ecard)
(require 'ecard-compat)
(require 'iso8601)

(defun my/calendar-date-to-org-timestamp (date)
  "Format calendar-gregorian DATE to a Org timestamp."
  (let ((time (encode-time 0 0 0 (nth 1 date) (nth 0 date) (nth 2 date))))
    (format-time-string "%Y-%m-%d %a" time)))

(defun my/ecard-to-vulpea-note (ecard)
  "Convert ecard ECARD into a string representing a vulpea headline note."
  (let* ((uid-value (ecard-get-property-value ecard 'uid))
         (fn-value (ecard-get-property-value ecard 'fn))
         (tel-props (ecard-tel ecard))
         (email-props (ecard-email ecard))
         (adr-props (ecard-adr ecard))
         (bday-value (ecard-get-property-value ecard 'bday))
         (note-value (ecard-get-property-value ecard 'note))
         (output ""))

    ;; headline and ID
    (setq output (concat output (format "* %s
:PROPERTIES:
:ID: %s
:END:
" fn-value uid-value)))

    ;; TEL
    (dolist (tel-prop tel-props)
      (let* ((type (alist-get "TYPE" (ecard-property-parameters tel-prop) nil nil #'string=))
             (tel-value (ecard-property-value tel-prop)))
        (pcase type
          ("cell,voice" (setq output (concat output (format "- mobile_phone_number :: %s
" tel-value))))

          ("home,voice" (setq output (concat output (format "- home_phone_number :: %s
" tel-value))))
          ("work,voice" (setq output (concat output (format "- work_phone_number :: %s
" tel-value))))
          (_ (user-error "Unknown tel parameters: %S" type)))))

    ;; EMAIL
    (dolist (email-prop email-props)
      (let* ((type (alist-get "TYPE" (ecard-property-parameters email-prop) nil nil #'string=))
             (email-value (ecard-property-value email-prop)))
        (pcase type
          ("home" (setq output (concat output (format "- personal_email_address :: %s
" email-value))))
          (_ (user-error "Unknown email parameters: %S" type)))))

    ;; ADR
    (dolist (adr-prop adr-props)
      (let* ((type (alist-get "TYPE" (ecard-property-parameters adr-prop) nil nil #'string=))
             (adr-value (ecard-property-value adr-prop))
             address
             region)
        (pcase adr-value
          (`("" "" ,a "" "" "" ,b) (progn
                                     (setq address a)
                                     (setq region b)
                                     ))
          (_ (user-error "Address should only contain region and address")))
        (pcase type
          ("home" (progn
                    (setq output (concat output (format "- home_address :: %s
" address)))
                    (setq output (concat output (format "- home_region :: %s
" region)))
                    ))
          (_ (user-error "Unknown adr parameters: %S" type)))
        ))

    ;; BDAY
    (when bday-value
      (let* ((parsed (iso8601-parse bday-value)))
        (pcase parsed
          (`(nil nil nil ,day ,month nil nil -1 nil)
           (setq output (concat output (format "- birthday :: <%s +1y>
" (my/calendar-date-to-org-timestamp (list month day 1583))))))
          (`(nil nil nil ,day ,month ,year nil -1 nil)
           (setq output (concat output (format "- birthday :: <%s +1y>
" (my/calendar-date-to-org-timestamp (list month day year)))))))))

    ;; NOTE
    (when note-value
      (setq output (concat output (format "- note :: %s
" note-value))))

    (concat output "\n")))

(defun my/ecard-parse-file (file)
  "Parse a vCard file FILE into a file-level vulpea note."
  (let* ((ecards (ecard-compat-parse-file file)))
    (cl-loop
     for ecard in ecards
     concat (my/ecard-to-vulpea-note ecard))))

;;;###autoload
(defun my/vcard-to-org ()
  "Convert ~/org/contacts.vcf to ~/org/contacts.org."
  (interactive)
  (let* ((contents (my/ecard-parse-file (expand-file-name "~/org/contacts.vcf")))
         (buf (find-file-noselect (expand-file-name "~/org/contacts.org"))))
    (with-current-buffer buf
      (erase-buffer)
      (insert (format ":PROPERTIES:
:ID: contacts
:END:
#+filetags: :area:contact:

") contents)
      (save-buffer))))

(provide 'my-ecard)
;;; my-ecard.el ends here
