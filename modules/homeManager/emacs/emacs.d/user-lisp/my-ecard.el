;;; my-ecard.el --- my-ecard.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'calendar)
(require 'cl-lib)
(require 'ecard)
(require 'ecard-compat)
(require 'iso8601)
(require 'vulpea-db)

(defun my/calendar-date-to-org-timestamp (date)
  "Format calendar-gregorian DATE to a Org timestamp."
  (let ((time (encode-time 0 0 0 (nth 1 date) (nth 0 date) (nth 2 date))))
    (format-time-string "%Y-%m-%d %a" time)))

(defun my/calendar-date-to-bday (date)
  "Format calendar-gregorian DATE to a vCard BDAY.

If the year is 1583, then year is omitted."
  (let* ((year (nth 2 date))
         (time (encode-time 0 0 0 (nth 1 date) (nth 0 date) year)))
    (if (equal year 1583)
        (format-time-string "--%m%d" time)
      (format-time-string "%Y%m%d" time))))

(defun my/ecard-to-vulpea-note (ecard)
  "Convert ecard ECARD into a string representing a vulpea headline note."
  (let* ((uid-value (ecard-get-property-value ecard 'uid))
         (fn-value (ecard-get-property-value ecard 'fn))
         (tel-props (reverse (ecard-tel ecard)))
         (email-props (reverse (ecard-email ecard)))
         (adr-props (reverse (ecard-adr ecard)))
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
  (with-current-buffer (find-file-noselect (expand-file-name "~/org/contacts.org"))
    (erase-buffer)
    (insert (format ":PROPERTIES:
:ID: contacts
:END:
#+filetags: :area:contact:

") (my/ecard-parse-file (expand-file-name "~/org/contacts.vcf")))
    (save-buffer)))

(defun my/vulpea-note-to-ecard (note)
  "Convert a vulpea note NOTE to ecard."
  (let* ((fn (vulpea-note-title note))
         (ecard (ecard-create-struct))
         (home-addresses (vulpea-note-meta-get-list note "home_address"))
         (home-regions (vulpea-note-meta-get-list note "home_region"))
         (addresses (seq-mapn (lambda (address region) (list "" "" address "" "" "" region)) home-addresses home-regions))
         (mobile-phone-number-props (seq-map (lambda (value)
                                               (ecard-property-create :name "TEL" :value value :parameters '(("TYPE" . "cell,voice"))))
                                             (vulpea-note-meta-get-list note "mobile_phone_number")))
         (home-phone-number-props (seq-map (lambda (value)
                                             (ecard-property-create :name "TEL" :value value :parameters '(("TYPE" . "home,voice"))))
                                           (vulpea-note-meta-get-list note "home_phone_number")))
         (work-phone-number-props (seq-map (lambda (value)
                                             (ecard-property-create :name "TEL" :value value :parameters '(("TYPE" . "work,voice"))))
                                           (vulpea-note-meta-get-list note "work_phone_number")))
         (tel-props (append mobile-phone-number-props home-phone-number-props work-phone-number-props nil))
         (tel-props (seq-sort-by (lambda (prop) (ecard-property-value prop)) #'string< tel-props)))
    (ecard-set-property ecard 'uid (vulpea-note-id note))
    (ecard-set-property ecard 'fn fn)
    (ecard-set-property ecard 'n (list nil fn nil nil nil))

    (ecard--set-slot-value ecard 'tel tel-props)

    (dolist (value (vulpea-note-meta-get-list note "personal_email_address"))
      (ecard-add-property ecard 'email value '(("TYPE" . "internet,home"))))

    (dolist (value addresses)
      (ecard-add-property ecard 'adr value '(("TYPE" . "home"))))

    (when-let* ((bday (vulpea-note-meta-get note "birthday"))
                (decode-time (org-parse-time-string bday))
                (value (pcase decode-time
                         (`(0 0 0 ,day ,month ,year nil -1 nil) (my/calendar-date-to-bday (list month day year)))
                         (_ (user-error "Unsupported birthday: %S" bday)))))
      (ecard-set-property ecard 'bday value))

    (when-let* ((value (vulpea-note-meta-get note "note")))
      (ecard-set-property ecard 'note value))

    ecard))

(defun my/ecard-compat-serialize (ecard)
  "Serialize ECARD to vCard 3.0."
  (let ((lines '("BEGIN:VCARD" "VERSION:3.0")))

    (dolist (slot '(uid adr anniversary bday caladruri caluri categories clientpidmap
                        email fburl fn gender geo impp key kind lang logo member n nickname
                        note org photo prodid related rev role sound source tel title tz url xml))
      (let ((props (ecard--slot-value ecard slot)))
        (when props
          (setq lines (append lines (ecard-compat--serialize-properties-30 props))))))

    (let ((extended (ecard-extended ecard)))
      (dolist (entry extended)
        (let ((props (cdr entry)))
          (setq lines (append lines (ecard-compat--serialize-properties-30 props))))))

    (setq lines (append lines '("END:VCARD")))

    (mapconcat #'identity lines "\n")))

(defun my/ecard-compat-serialize-multiple (ecards)
  "Serialize ECARDS to vCard 3.0."
  (mapconcat #'my/ecard-compat-serialize ecards "\n"))

;;;###autoload
(defun my/org-to-vcard ()
  "Convert ~/org/contacts.org to ~/org/contacts.vcf."
  (interactive)
  (let* (ecards vcard-str)
    (with-current-buffer (find-file-noselect (expand-file-name "~/org/contacts.org"))
      (setq ecards (seq-filter #'identity (org-map-entries (lambda ()
                                                             (let* ((id (org-entry-get (point) "ID")))
                                                               (if id
                                                                   (my/vulpea-note-to-ecard (vulpea-db-get-by-id id))
                                                                 (message "Skipping headline without ID: %s" (org-get-heading 'no-tags 'no-todo 'no-priority 'no-comment))
                                                                 nil)))))))
    (setq vcard-str (my/ecard-compat-serialize-multiple ecards))
    (with-current-buffer (find-file-noselect (expand-file-name "~/org/contacts.vcf"))
      (erase-buffer)
      (insert vcard-str "\n")
      (save-buffer))))

(provide 'my-ecard)
;;; my-ecard.el ends here
