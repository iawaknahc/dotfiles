;;; init-world-clock-mode.el --- init-world-clock-mode.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'solar)
(require 'iso8601)

;;;; Custom variables
(defcustom my/world-clock-zoneinfo-directory "/usr/share/zoneinfo"
  "The path to the zoneinfo directory."
  :type 'directory
  :group 'my/world-clock)

(defcustom my/world-clock-cldr-json-directory nil
  "The path to the cldr-json directory.

There are some implications if it is nil.
See `my/world-clock-business-hours'."
  :type 'directory
  :group 'my/world-clock)

(defcustom my/world-clock-cldr-json-locale "en"
  "The locale to display localized timezone names.

No locale negotiation is performed,
thus, the value must match one of the supported values."
  :type 'string
  :group 'my/world-clock)

(defcustom my/world-clock-home-timezone nil
  "The home timezone.

If it is nil, then it is taken from the environment variable TZ.
If TZ is nil or an empty string, then \"Etc/UTC\" is the home timezone.

The home timezone is displayed as the first item in the list.
The offset between the home timezone and the other timezone determines the order of
the other timezone in the list."
  :type 'string
  :group 'my/world-clock)

(defcustom my/world-clock-zoneinfo-list nil
  "A list of zoneinfo names.

This list is used to derived `zoneinfo-style-world-list'.")

(defcustom my/world-clock-business-hours '("09:00" "18:00")
  "Business hours as a list (START END) of \"HH:MM\" strings.

The times are local to each timezone.

If START is equal to END, there is no business hour.

If START is less than END,
then a time T is within business hours if START <= T < END.

If START is greater than END,
then T is within business hours if T >= START or T < END.
This case is also known as an overnight shift.
A shift belongs to the day it starts on.
For example, assume business hours is (\"22:00\" \"06:00\").
Friday 22:00 to Saturday 06:00 is within business hours,
but Sunday 22:00 to Monday 06:00 is not,
assuming Saturday and Sunday are weekends.

Business hours is applicable on business days.
Business days are on weekdays.
For generic timezones like Etc/UTC, there are no business days.

When cldr-json is available, weekends are determined from it.
Otherwise, Saturdays and Sundays are considered as weekends.

Public holidays are not considered."
  :type '(list (string :tag "Start") (string :tag "End"))
  :group 'my/world-clock)

;;;; Internal variables
(defconst my/world-clock--continent-or-ocean-list
  '("Africa"
    "America"
    "Antarctica"
    "Asia"
    "Europe"
    "Australia"
    "Pacific"
    "Atlantic"
    "Indian"
    "Arctic")
  "The list of continent or ocean.")

(defvar-local my/world-clock-time nil
  "The time being displayed in the buffer.

It is number of seconds since the UNIX epoch.
In other words, the return value of (time-convert TIME 'integer).")

(defvar my/world-clock--timezones nil
  "A list of plists representing a timezone.

The plist has the following properties:
- :name The name of the timezone
- :aliases The list of aliases
- :alpha2 The ISO 3166 alpha-2 code of the most populous area the timezone covers
- :latitude The latitude of the principle location of the timezone
- :longitude The longitude of the principle location of the timezone

Except :name, all properties can be nil.")

(defvar my/world-clock--timezones-index nil
  "Hash table from timezone name or alias to plist.")

(defvar my/world-clock--cldr-json-weekData-json nil
  "See `my/world-clock--parse-cldr-json-weekData-json'.")

(defvar my/world-clock--cldr-json-primary-zones nil
  "A list of plists associating a ISO 3166 alpha-2 code to its primary zone.

The plist has the following properties:
- :alpha2 The ISO 3166 alpha-2 code
- :timezone The name of the primary zone

All properties are non-nil.")

(defvar my/world-clock--cldr-json-territory-names nil
  "A list of plists containing localized territory names.
Localized according to `my/world-clock-cldr-json-locale'.

The plist has the following properties:
- :alpha2 The ISO 3166 alpah-2 code
- :name The name
- :short-name The short name

:alpha2 and :name are non-nil.")

(defvar my/world-clock--cldr-json-territory-names-index nil
  "Hash table from alpha2 to plist.")

(defvar my/world-clock--cldr-json-timezone-localization nil
  "A plist with the following properties.

- :region-format A string containing \"{0}\"
- :region-format-daylight A string containing \"{0}\"
- :region-format-standard A string containing \"{0}\"
- :fallback-format A string containing \"{0}\" and \"{1}\"
- :timezones A list of plists.  See below.
- :metazones A list of plists.  See below.
All of them are non-nil.

The timezone plist have the following properties:
- :name The name of the timezone, e.g. \"America/Argentina/Tucuman\"
- :long A plist.  See below.
- :short A plist.  See below.
- :exemplar-city A string.
:name is non-nil.
Of the other properties, at least one of them are non-nil.

The metazone plist have the following properties:
- :name The long ID of the metazone, e.g. \"America_Pacific\"
- :long A plist. See below.
- :short A plist. See below.
:name is non-nil.
Of the other properties, at least one of them are non-nil.

The short or long plist have the following properties:
- :generic A string
- :daylight A string
- :standard A string
At least one of them are non-nil.")

(defvar my/world-clock--cldr-json-timezone-localization-timezones-index nil
  "Hash table from timezone name or its BCP47 alias to timezone plist.

See `my/world-clock--cldr-json-timezone-localization'.")

(defvar my/world-clock--cldr-json-timezone-localization-metazones-index nil
  "Hash table from metazone long ID to metazone plist.

See `my/world-clock--cldr-json-timezone-localization'.")

(defvar my/world-clock--cldr-json-bcp47-timezones nil
  "A list of plists representing a cldr-json BCP47 timezone.

The plist has the following properties:
- :locode The short identifier
- :alpha2 The ISO 3166 alpha-2 associated with the timezone
- :aliases The list of aliases.

Except :locode and :aliases, all properties can be nil.")

(defvar my/world-clock--cldr-json-bcp47-timezones-index nil
  "Hash table from locode or alias to plist.")

(defvar my/world-clock--cldr-json-bcp47-timezones-index-by-alpha2 nil
  "Hash table from alpha2 to a list of plists.")

(defvar my/world-clock--cldr-json-metazones nil
  "A list of plists representing a cldr-json metazone.

The plist has the following properties:
- long-id: The long identifier
- short-id: The short identifier
- map-zones: A plist mapping the metazone to its golden zone or preferred zone.
  For example, (:001 \"America/Los_Angeles\" :CA \"America/Vancouver\")

All properties are never nil.")

(defvar my/world-clock--cldr-json-metazones-index nil
  "Hash table from short-id or long-id to plist.")

(defvar my/world-clock--cldr-json-metazone-mappings nil
  "A list of plists mapping a timezone to a metazone.

The plist has the following properties:
- :name The name of the timezone
- :mappings A plist mapping the timezone to its metazone

:name is never nil.
:mappings may be nil if the timezone is not associated with a metazone.

The mapping plist has the following properties:
- :metazone The long ID of the metazone
- :from A Emacs time value indicating the start time of this mapping.
- :to A Emacs time value indicating the end time of this mapping.

If both :from and :to are nil, the mapping is always in effect.
If only :from is non-nil, the mapping is in effect if TIME >= :from.
If only :to is non-nil, the mapping is in effect if TIME < :to.")

(defvar my/world-clock--cldr-json-metazone-mappings-index nil
  "Hash table from timezone name or its BCP47 alias to plist.")

(defvar my/world-clock--cldr-json-metazone-mappings-reverse nil
  "A list of plists mapping a metazone to its member timezones.

The plist has the following properties:
- :metazone The long ID of the metazone
- :memberships A list of plist.  See below.
Both are non-nil.

The membership plist has the following properties:
- :name The name of the timezone
- :from A Emacs time value indicating the start time of this membership.
- :to A Emacs time value indicating the end time of this membership.
:name is non-nil.

If both :from and :to are nil, the membership is always in effect.
If only :from is non-nil, the membership is in effect if TIME >= :from.
If only :to is non-nil, the membership is in effect if TIME < :to.")

(defvar my/world-clock--cldr-json-metazone-mappings-reverse-index nil
  "Hash table from metazone long ID or short ID to plist.")

(defvar-local my/world-clock--utc-offset-cache nil
  "See `my/world-clock--utc-offset'.")

(defvar-local my/world-clock--utc-offset-cache-time nil
  "See `my/world-clock--utc-offset'.")

(defvar-local my/world-clock--min-max-utc-offsets-cache nil
  "See `my/world-clock--min-max-utc-offsets'.")

;; In `world-clock', `world-clock-display' is called before `world-clock-mode',
;; erasing all non-permanent buffer-local variables.
(put 'my/world-clock-time 'permanent-local t)
(put 'my/world-clock-home-timezone 'permanent-local t)
(put 'zoneinfo-style-world-list 'permanent-local t)

;; Declare them special so that the `let*' below binds them dynamically,
;; even if org is not loaded yet.
(defvar org-read-date-popup-calendar)
(defvar org-read-date-force-compatible-dates)

;;;; Commands
(defun my/world-clock-now ()
  "Move the clock to now."
  (interactive)
  (setq my/world-clock-time (time-convert (current-time) 'integer))
  (my/world-clock--update))

(defun my/world-clock-backward-15-minutes ()
  "Move the clock backward to the previous quarter hour."
  (interactive)
  (my/world-clock--move (* -15 60)))

(defun my/world-clock-forward-15-minutes ()
  "Move the clock forward to the next quarter hour."
  (interactive)
  (my/world-clock--move (* 15 60)))

(defun my/world-clock-backward-1-hour ()
  "Move the clock backward to the previous full hour."
  (interactive)
  (my/world-clock--move (* -1 60 60)))

(defun my/world-clock-forward-1-hour ()
  "Move the clock forward to the next full hour."
  (interactive)
  (my/world-clock--move (* 1 60 60)))

(defun my/world-clock-jump ()
  "Move the clock to the time obtained by `org-read-date'."
  (interactive)
  (let* ((org-read-date-popup-calendar nil)
         ;; Allow dates outside 1970-2037.
         (org-read-date-force-compatible-dates nil))
    (setq my/world-clock-time (time-convert (org-read-date t t nil nil my/world-clock-time) 'integer)))
  (my/world-clock--update))

(defun my/world-clock-change-home-timezone ()
  "Change home timezone."
  (interactive)
  (let* ((time my/world-clock-time)
         (home-timezone (my/world-clock--home-timezone))
         (timezones (my/world-clock--get-home-timezones time home-timezone))
         (selected (my/world-clock--completing-read
                    "Select a new home timezone: "
                    timezones
                    (my/world-clock--completing-read-label-function-for-timezone time home-timezone))))
    (when selected
      (setq-local my/world-clock-home-timezone (my/world-clock--canonicalize selected))
      (my/world-clock--update))))

(defun my/world-clock-display-timezones-by-alpha2 ()
  "Display the list of timezones by selecting a ISO 3166 alpha-2 code."
  (interactive)
  (let* ((alpha2-list (my/world-clock--get-alpha2-list))
         (alpha2 (my/world-clock--completing-read
                  "Select a ISO 3166 alpha-2 code: "
                  alpha2-list
                  #'my/world-clock--completing-read-label-function-for-alpha2)))
    (when alpha2
      (my/world-clock--prepare-timezones)
      (let* ((home-timezone (my/world-clock--home-timezone))
             (plists (seq-filter (lambda (plist)
                                   (string= alpha2 (plist-get plist :alpha2)))
                                 my/world-clock--timezones))
             (timezones (seq-map (lambda (plist) (plist-get plist :name)) plists))
             (timezones (my/world-clock--sort-timezones timezones my/world-clock-time home-timezone))
             (timezones (my/world-clock--add-home-to-list home-timezone timezones)))
        (setq-local zoneinfo-style-world-list
                    (my/world-clock--timezones-to-zoneinfo-style-world-list timezones home-timezone)))
      (my/world-clock--update))))

(defun my/world-clock-display-timezones-by-continent-or-ocean ()
  "Display the list of timezones by selecting a continent or an ocean."
  (interactive)
  (let* ((continent-or-ocean (my/world-clock--completing-read
                              "Select a continent or an ocean: "
                              my/world-clock--continent-or-ocean-list
                              #'identity)))
    (when continent-or-ocean
      (my/world-clock--prepare-timezones)
      (let* ((home-timezone (my/world-clock--home-timezone))
             (plists (seq-filter (lambda (plist)
                                   (or
                                    (my/world-clock--prefix-p continent-or-ocean (plist-get plist :name))
                                    (seq-some (lambda (alias) (my/world-clock--prefix-p continent-or-ocean alias)) (plist-get plist :aliases))))
                                 my/world-clock--timezones))
             (timezones (seq-map (lambda (plist) (plist-get plist :name)) plists))
             (timezones (my/world-clock--sort-timezones timezones my/world-clock-time home-timezone))
             (timezones (my/world-clock--add-home-to-list home-timezone timezones)))
        (setq-local zoneinfo-style-world-list
                    (my/world-clock--timezones-to-zoneinfo-style-world-list timezones home-timezone)))
      (my/world-clock--update))))

(defun my/world-clock-display-timezones-by-default ()
  "Display the list of timezones indicated by `my/world-clock-zoneinfo-list'."
  (interactive)
  (let* ((home-timezone (my/world-clock--home-timezone))
         (timezones (seq-map #'my/world-clock--canonicalize my/world-clock-zoneinfo-list))
         (timezones (my/world-clock--sort-timezones timezones my/world-clock-time home-timezone))
         (timezones (my/world-clock--add-home-to-list home-timezone timezones)))
    (setq-local zoneinfo-style-world-list
                (my/world-clock--timezones-to-zoneinfo-style-world-list timezones home-timezone)))
  (my/world-clock--update))

(defun my/world-clock-display-timezones-all ()
  "Display the list of all timezones."
  (interactive)
  (let* ((home-timezone (my/world-clock--home-timezone))
         (timezones (seq-map (lambda (plist) (plist-get plist :name)) my/world-clock--timezones))
         (timezones (my/world-clock--sort-timezones timezones my/world-clock-time home-timezone))
         (timezones (my/world-clock--add-home-to-list home-timezone timezones)))
    (setq-local zoneinfo-style-world-list
                (my/world-clock--timezones-to-zoneinfo-style-world-list timezones home-timezone)))
  (my/world-clock--update))

;;;; Internal functions
(defun my/world-clock--home-timezone ()
  "Resolve `my/world-clock-home-timezone'."
  (my/world-clock--canonicalize (or my/world-clock-home-timezone
                                    (when-let* ((tz (getenv "TZ")))
                                      (and (not (string-empty-p tz)) tz))
                                    "Etc/UTC")))

(defun my/world-clock--move (delta)
  "Move the clock to the adjacent multiple of DELTA.

DELTA is an integer number of seconds.
If DELTA is positive, move forward.
IF DELTA is negative, move backward.
IF DELTA is zero, this function does nothing."
  (unless (zerop delta)
    (let* ((sum (time-add my/world-clock-time delta))
           (mod (mod my/world-clock-time delta))
           (result (- sum mod)))
      (setq my/world-clock-time result))
    (my/world-clock--update)))

(defun my/world-clock--update ()
  "Set `zoneinfo-style-world-list' and invoke `world-clock-update'."
  (let* ((time my/world-clock-time)
         (home-timezone (my/world-clock--home-timezone))
         (timezones (seq-map #'car zoneinfo-style-world-list))
         (timezones (my/world-clock--sort-timezones timezones time home-timezone))
         (timezones (my/world-clock--add-home-to-list home-timezone timezones)))
    (setq-local zoneinfo-style-world-list
                (my/world-clock--timezones-to-zoneinfo-style-world-list timezones home-timezone)))
  (world-clock-update))

(defun my/world-clock--add-home-to-list (home-timezone timezones)
  "Add HOME-TIMEZONE to the head of TIMEZONES.

If HOME-TIMEZONE is already in TIMEZONES,
it will be moved to the front."
  (let* ((timezones (seq-filter (lambda (timezone)
                                  (not (string= timezone home-timezone)))
                                timezones)))
    (append (list home-timezone) timezones nil)))

(defun my/world-clock--timezones-to-zoneinfo-style-world-list (timezones home-timezone)
  "Convert TIMEZONES to `zoneinfo-style-world-list' with HOME-TIMEZONE."
  (seq-map (lambda (timezone)
             (list timezone (my/world-clock--label timezone my/world-clock-time home-timezone)))
           timezones))

(defun my/world-clock--sort-timezones (timezones time home-timezone)
  "Sort TIMEZONES in increasing hour with respect to TIME and HOME-TIMEZONE."
  (sort timezones
        :key (lambda (timezone)
               (let* ((diff-in-seconds (my/world-clock--diff time home-timezone timezone)))
                 ;; The order is in increasing hours.
                 (if (< diff-in-seconds 0)
                     (+ diff-in-seconds (* 86400 10))
                   diff-in-seconds)))))

(defun my/world-clock--before ()
  "Set `my/world-clock-time'."
  (let* ((buffer (get-buffer-create world-clock-buffer-name)))
    (with-current-buffer buffer
      (setq-local my/world-clock-time (time-convert (current-time) 'integer))
      (setq-local my/world-clock-home-timezone (default-value 'my/world-clock-home-timezone))
      (let* ((home-timezone (my/world-clock--home-timezone))
             (timezones (seq-map #'my/world-clock--canonicalize my/world-clock-zoneinfo-list))
             (timezones (my/world-clock--sort-timezones timezones my/world-clock-time home-timezone))
             (timezones (my/world-clock--add-home-to-list home-timezone timezones)))
        (setq-local zoneinfo-style-world-list
                    (my/world-clock--timezones-to-zoneinfo-style-world-list timezones home-timezone))))))

(defun my/world-clock-display--around (fn &rest args)
  "Forward ARGS to FN."
  ;; Dynamically bind `current-time'.
  (cl-letf (((symbol-function 'current-time) (lambda () my/world-clock-time)))
    (apply fn args)))

(defun my/world-clock-display--after (&rest _)
  "Apply the face stored in `my/world-clock--face' and `my/world-clock--business-hours-face'."
  (let ((inhibit-read-only t)
        (pos (point-min)))
    (while (setq pos (text-property-not-all pos (point-max) 'my/world-clock--face nil))
      (let ((end (next-single-property-change pos 'my/world-clock--face nil (point-max))))
        (add-face-text-property pos end (get-text-property pos 'my/world-clock--face))
        (setq pos end)))
    ;; The business hours face is stored on the label,
    ;; but it is applied to the time after the label on the same line.
    (setq pos (point-min))
    (while (setq pos (text-property-not-all pos (point-max) 'my/world-clock--business-hours-face nil))
      (let ((face (get-text-property pos 'my/world-clock--business-hours-face))
            (end (next-single-property-change pos 'my/world-clock--business-hours-face nil (point-max))))
        (save-excursion
          (goto-char end)
          ;; Skip the padding between the label and the time.
          (skip-chars-forward " ")
          (add-face-text-property (point) (line-end-position) face))
        (setq pos end)))))

(defun my/world-clock--parse-coordinates (s)
  "Parse the coordinates S in format ±DDMM±DDDMM or ±DDMMSS±DDDMMSS.

Return a 2-element list containing the latitude and the longitude."
  (save-match-data
    (when (string-match (rx-let ((sign (or "+" "-"))
                                 (dd (seq digit digit))
                                 (ddd (seq digit digit digit))
                                 (mm (seq digit digit))
                                 (ss (seq digit digit)))
                          (rx
                           (or
                            (seq (group-n 1 sign)
                                 (group-n 2 dd)
                                 (group-n 3 mm)
                                 (group-n 5 sign)
                                 (group-n 6 ddd)
                                 (group-n 7 mm))
                            (seq (group-n 1 sign)
                                 (group-n 2 dd)
                                 (group-n 3 mm)
                                 (group-n 4 ss)
                                 (group-n 5 sign)
                                 (group-n 6 ddd)
                                 (group-n 7 mm)
                                 (group-n 8 ss)))))
                        s)
      (let* ((lat-sign (pcase (match-string 1 s)
                         ("-" -1.0)
                         ("+" +1.0)))
             (lat-deg (string-to-number (match-string 2 s) 10))
             (lat-min (/ (string-to-number (match-string 3 s) 10) 60.0))
             (lat-sec (/ (string-to-number (or (match-string 4 s) "0") 10) 3600.0))
             (lng-sign (pcase (match-string 5 s)
                         ("-" -1.0)
                         ("+" +1.0)))
             (lng-deg (string-to-number (match-string 6 s) 10))
             (lng-min (/ (string-to-number (match-string 7 s) 10) 60.0))
             (lng-sec (/ (string-to-number (or (match-string 8 s) "0") 10) 3600.0)))
        (list (* lat-sign (+ lat-deg lat-min lat-sec)) (* lng-sign (+ lng-deg lng-min lng-sec)))))))

(defun my/world-clock--parse-zone-tab ()
  "Parse the file zone.tab in directory `my/world-clock-zoneinfo-directory'."
  (let* (result)
    (with-temp-buffer
      (insert-file-contents (expand-file-name "zone.tab" my/world-clock-zoneinfo-directory))
      (goto-char (point-min))
      (while (not (eobp))
        (when-let* ((_ (not (eql (char-after) ?#)))
                    (line (buffer-substring-no-properties (pos-bol) (pos-eol)))
                    (parts (split-string line (rx "\t")))
                    (ele (pcase parts
                           ((or
                             `( ,alpha2 ,coordinates ,timezone-name)
                             `( ,alpha2 ,coordinates ,timezone-name ,_))
                            (pcase-let* ((`(,lat ,lng) (my/world-clock--parse-coordinates coordinates)))
                              (list :name timezone-name :alpha2 alpha2 :latitude lat :longitude lng)))
                           (_ (user-error "Unrecognized line %S" parts)))))
          (push ele result))
        (forward-line 1)))
    result))

(defun my/world-clock--parse-tzdata-zi ()
  "Parse the file tzdata.zi in directory `my/world-clock-zoneinfo-directory'."
  (let* (result)
    (with-temp-buffer
      (insert-file-contents (expand-file-name "tzdata.zi" my/world-clock-zoneinfo-directory))
      (goto-char (point-min))
      (while (not (eobp))
        (when-let* ((_ (not (eql (char-after) ?#)))
                    (line (buffer-substring-no-properties (pos-bol) (pos-eol))))
          (pcase (char-after)
            (?Z
             (let* ((parts (split-string line (rx " ")))
                    (name (nth 1 parts)))
               (push (list :name name :aliases nil) result)))
            (?L
             (let* ((parts (split-string line (rx " ")))
                    (canonical (nth 1 parts))
                    (alias (nth 2 parts))
                    (plist (seq-find (lambda (plist)
                                       (string= canonical (plist-get plist :name)))
                                     result)))
               (push alias (plist-get plist :aliases))))))
        (forward-line 1)))
    result))

(defun my/world-clock--parse-iso3166-tab ()
  "Parse the file iso3166.tab in directory `my/world-clock-zoneinfo-directory'."
  (let* (result)
    (with-temp-buffer
      (insert-file-contents (expand-file-name "iso3166.tab" my/world-clock-zoneinfo-directory))
      (goto-char (point-min))
      (while (not (eobp))
        (when-let* ((_ (not (eql (char-after) ?#)))
                    (line (buffer-substring-no-properties (pos-bol) (pos-eol)))
                    (parts (split-string line (rx "\t")))
                    (ele (pcase parts
                           (`( ,alpha2 ,alpha2-name)
                            (list :alpha2 alpha2 :alpha2-name alpha2-name))
                           (_ (user-error "Unrecognized line %S" parts)))))
          (push ele result))
        (forward-line 1)))
    result))

(defun my/world-clock--parse-timezones ()
  "Parse the data files in directory `my/world-clock-zoneinfo-directory'.

zone.tab is the primary list, so that each country has its own timezone,
even if tzdata.zi makes it a link to a timezone of another country.
For example, Europe/Amsterdam is a link to Europe/Brussels in tzdata.zi.

Timezones in tzdata.zi that are absent from zone.tab, like Etc/UTC, are added.
Links in tzdata.zi become aliases, unless the alias is in zone.tab."
  (let* ((tzdata-zi (my/world-clock--parse-tzdata-zi))
         (zone-tab (my/world-clock--parse-zone-tab))
         (iso3166-tab (my/world-clock--parse-iso3166-tab))
         (zone-tab-names (seq-map (lambda (plist) (plist-get plist :name)) zone-tab))
         result)
    (dolist (zone-tab-entry zone-tab)
      (let* ((alpha2 (plist-get zone-tab-entry :alpha2))
             (iso3166-tab-entry (seq-find (lambda (plist) (string= alpha2 (plist-get plist :alpha2))) iso3166-tab)))
        (push
         (list
          :name (plist-get zone-tab-entry :name)
          :aliases nil
          :alpha2 alpha2
          :alpha2-name (plist-get iso3166-tab-entry :alpha2-name)
          :latitude (plist-get zone-tab-entry :latitude)
          :longitude (plist-get zone-tab-entry :longitude))
         result)))
    (dolist (tzdata-zi-entry tzdata-zi)
      (let* ((name (plist-get tzdata-zi-entry :name))
             (aliases (seq-remove (lambda (alias) (member alias zone-tab-names))
                                  (plist-get tzdata-zi-entry :aliases)))
             (plist (seq-find (lambda (plist) (string= name (plist-get plist :name))) result)))
        (if plist
            (setf (plist-get plist :aliases) aliases)
          (push
           (list
            :name name
            :aliases aliases
            :alpha2 nil
            :alpha2-name nil
            :latitude nil
            :longitude nil)
           result))))
    result))

(defun my/world-clock--prepare-timezones ()
  "Prepare `my/world-clock--timezones'."
  (unless my/world-clock--timezones
    (setq my/world-clock--timezones (my/world-clock--parse-timezones)))
  (unless my/world-clock--timezones-index
    (setq my/world-clock--timezones-index (make-hash-table :test #'equal))
    (dolist (plist my/world-clock--timezones)
      (puthash (plist-get plist :name) plist my/world-clock--timezones-index)
      (dolist (alias (plist-get plist :aliases))
        (puthash alias plist my/world-clock--timezones-index)))))

(defun my/world-clock--parse-cldr-json-weekData-json ()
  "Parse the file cldr-core/supplemental/weekData.json at `my/world-clock-cldr-json-directory'.

If `my/world-clock-cldr-json-directory' is nil, return nil."
  (when my/world-clock-cldr-json-directory
    (with-temp-buffer
      (insert-file-contents (expand-file-name "./cldr-core/supplemental/weekData.json" my/world-clock-cldr-json-directory))
      (goto-char (point-min))
      (let* ((result (json-parse-buffer :object-type 'plist
                                        :array-type 'array)))
        result))))

(defun my/world-clock--parse-cldr-json-territory-names ()
  "Parse the file cldr-localenames-full/main/*/territories.json at `my/world-clock-cldr-json-directory'.

If `my/world-clock-cldr-json-directory' is nil, return nil."
  (when-let* ((root (when my/world-clock-cldr-json-directory
                      (with-temp-buffer
                        (insert-file-contents (expand-file-name
                                               (format "./cldr-localenames-full/main/%s/territories.json" my/world-clock-cldr-json-locale)
                                               my/world-clock-cldr-json-directory))
                        (goto-char (point-min))
                        (let* ((result (json-parse-buffer :object-type 'plist
                                                          :array-type 'array)))
                          result))))
              (main (plist-get root :main))
              (locale (plist-get main (intern (concat ":" my/world-clock-cldr-json-locale))))
              (localeDisplayNames (plist-get locale :localeDisplayNames))
              (territories (plist-get localeDisplayNames :territories)))
    (cl-loop
     for (key value) on territories by #'cddr
     for alpha2 = (substring (symbol-name key) 1)
     for short-name = (when (eql 2 (length alpha2))
                        (plist-get territories (intern (concat ":" alpha2 "-alt-short"))))
     if (eql 2 (length alpha2))
     collect (list :alpha2 alpha2 :name value :short-name short-name))))

(defun my/world-clock--prepare-cldr-json-territory-names ()
  "Prepare `my/world-clock--cldr-json-territory-names'."
  (unless my/world-clock--cldr-json-territory-names-index
    (setq my/world-clock--cldr-json-territory-names-index (make-hash-table :test #'equal)))
  (unless my/world-clock--cldr-json-territory-names
    (setq my/world-clock--cldr-json-territory-names (my/world-clock--parse-cldr-json-territory-names))
    (dolist (plist my/world-clock--cldr-json-territory-names)
      (puthash (plist-get plist :alpha2) plist my/world-clock--cldr-json-territory-names-index))))

(defun my/world-clock--get-short-territory-name (alpha2)
  "Return the localized short name of ALPHA2.

If short name is unavailable, the name is returned.
Return nil if localization is unavailable."
  (my/world-clock--prepare-cldr-json-territory-names)
  (when-let* ((plist (gethash alpha2 my/world-clock--cldr-json-territory-names-index)))
    (or (plist-get plist :short-name) (plist-get plist :name))))

(defun my/world-clock--get-territory (alpha2)
  "Return the plist for ALPHA2."
  (my/world-clock--prepare-cldr-json-territory-names)
  (gethash alpha2 my/world-clock--cldr-json-territory-names-index))

(defun my/world-clock--parse-cldr-json-primary-zones ()
  "Parse the file cldr-core/supplemental/primaryZones.json at `my/world-clock-cldr-json-directory'.

if `my/world-clock-cldr-json-directory' is nil, return nil.
See `my/world-clock--cldr-json-primary-zones'."
  (when-let* ((root (when my/world-clock-cldr-json-directory
                      (with-temp-buffer
                        (insert-file-contents (expand-file-name "./cldr-core/supplemental/primaryZones.json" my/world-clock-cldr-json-directory))
                        (goto-char (point-min))
                        (let* ((result (json-parse-buffer :object-type 'plist
                                                          :array-type 'array)))
                          result))))
              (supplemental (plist-get root :supplemental))
              (primary-zones (plist-get supplemental :primaryZones)))
    (cl-loop
     for (key value) on primary-zones by #'cddr
     for alpha2 = (substring (symbol-name key) 1)
     collect (list :alpha2 alpha2 :timezone value))))

(defun my/world-clock--prepare-cldr-json-primary-zones ()
  "Prepare `my/world-clock--cldr-json-primary-zones'."
  (unless my/world-clock--cldr-json-primary-zones
    (setq my/world-clock--cldr-json-primary-zones (my/world-clock--parse-cldr-json-primary-zones))))

(defun my/world-clock--get-primary-zone (alpha2)
  "Return the primary zone of ALPHA2.

Return nil if ALPHA2 has no primary zone."
  (my/world-clock--prepare-cldr-json-primary-zones)
  (plist-get (seq-find (lambda (plist)
                         (string= (plist-get plist :alpha2) alpha2))
                       my/world-clock--cldr-json-primary-zones)
             :timezone))

(defun my/world-clock--parse-cldr-json-bcp47-timezones ()
  "Parse the file cldr-bcp47/bcp47/timezone.json at `my/world-clock-cldr-json-directory'.

If `my/world-clock-cldr-json-directory' is nil, return nil.
See `my/world-clock--cldr-json-bcp47-timezones'."
  (when-let* ((root (when my/world-clock-cldr-json-directory
                      (with-temp-buffer
                        (insert-file-contents (expand-file-name "./cldr-bcp47/bcp47/timezone.json" my/world-clock-cldr-json-directory))
                        (goto-char (point-min))
                        (let* ((result (json-parse-buffer :object-type 'plist
                                                          :array-type 'array)))
                          result))))
              (keyword (plist-get root :keyword))
              (u (plist-get keyword :u))
              (tz (plist-get u :tz)))
    (cl-loop
     for (key value) on tz by #'cddr
     for item = (let* ((key-str (substring (symbol-name key) 1)))
                  ;; Skip _description and similar.
                  (unless (string-prefix-p "_" key-str)
                    ;; Skip entry marked as deprecated.
                    (when (not (plist-get value :_deprecated))
                      (let* ((alias (plist-get value :_alias))
                             (iana (plist-get value :_iana))
                             (region (plist-get value :_region))
                             (iana (plist-get value :_iana))
                             (aliases (split-string alias " "))
                             (aliases (if iana (cons iana aliases) aliases))
                             alpha2)
                        ;; https://unicode.org/reports/tr35/tr35.html#Time_Zone_Identifiers
                        ;; 1. If the short identifier is of length 5, then it is associated with a region.
                        ;; 2. Otherwise, if it has a region attribute, then it is associated with a region.
                        (when (or (eql (length key-str ) 5) region)
                          (setq alpha2 (or region (upcase (substring key-str 0 2)))))
                        (list :locode key-str :alpha2 alpha2 :aliases aliases)))))
     when item collect item)))

(defun my/world-clock--prepare-cldr-json-bcp47-timezones ()
  "Prepare `my/world-clock--cldr-json-bcp47-timezones'."
  (unless my/world-clock--cldr-json-bcp47-timezones-index
    (setq my/world-clock--cldr-json-bcp47-timezones-index (make-hash-table :test #'equal)))
  (unless my/world-clock--cldr-json-bcp47-timezones-index-by-alpha2
    (setq my/world-clock--cldr-json-bcp47-timezones-index-by-alpha2 (make-hash-table :test #'equal)))
  (unless my/world-clock--cldr-json-bcp47-timezones
    (setq my/world-clock--cldr-json-bcp47-timezones (my/world-clock--parse-cldr-json-bcp47-timezones))
    (dolist (plist my/world-clock--cldr-json-bcp47-timezones)
      (when-let* ((alpha2 (plist-get plist :alpha2)))
        (puthash alpha2
                 (cons plist (gethash alpha2 my/world-clock--cldr-json-bcp47-timezones-index-by-alpha2))
                 my/world-clock--cldr-json-bcp47-timezones-index-by-alpha2))

      (puthash (plist-get plist :locode) plist my/world-clock--cldr-json-bcp47-timezones-index)
      (dolist (alias (plist-get plist :aliases))
        (puthash alias plist my/world-clock--cldr-json-bcp47-timezones-index)))))

(defun my/world-clock--get-bcp47-timezone (timezone)
  "Return the BCP47 timezone for TIMEZONE.

Return nil if not found."
  (my/world-clock--prepare-cldr-json-bcp47-timezones)
  (gethash timezone my/world-clock--cldr-json-bcp47-timezones-index))

(defun my/world-clock--get-bcp47-timezones-by-alpha2 (alpha2)
  "Return a list of BCP47 timezones associated with ALPHA2."
  (my/world-clock--prepare-cldr-json-bcp47-timezones)
  (gethash alpha2 my/world-clock--cldr-json-bcp47-timezones-index-by-alpha2))

(defun my/world-clock--sole-timezone-in-region-p (timezone)
  "Return a timezone if either of the following condition holds.

1. The region associated with TIMEZONE has only one timezone.
   In this case, return TIMEZONE.
2. The region associated with TIMEZONE has a primary timezone.
   In this case, return the primary timezone.

If TIMEZONE is not associated with a region, return nil."
  (when-let* ((timezone-plist (my/world-clock--get-plist timezone))
              (alpha2 (plist-get timezone-plist :alpha2)))
    (or
     (when (eql 1 (length (my/world-clock--get-bcp47-timezones-by-alpha2 alpha2))) timezone)
     (my/world-clock--get-primary-zone alpha2))))

(defun my/world-clock--parse-cldr-json-metazones ()
  "Parse the file cldr-core/supplemental/metaZones.json at `my/world-clock-cldr-json-directory'.

If `my/world-clock-cldr-json-directory' is nil, return nil.
Otherwise return a list of plist.
See `my/world-clock--cldr-json-metazones'."
  (when-let* ((root (when my/world-clock-cldr-json-directory
                      (with-temp-buffer
                        (insert-file-contents (expand-file-name "./cldr-core/supplemental/metaZones.json" my/world-clock-cldr-json-directory))
                        (goto-char (point-min))
                        (let* ((result (json-parse-buffer :object-type 'plist
                                                          :array-type 'array)))
                          result))))
              (supplemental (plist-get root :supplemental))
              (metaZones (plist-get supplemental :metaZones))
              (metazones1 (plist-get metaZones :metazones))
              (metazoneIds (plist-get metaZones :metazoneIds))
              (metazone-golden-zone-territory (cl-loop
                                               with table = (make-hash-table :test #'equal)
                                               for obj across metazones1
                                               for map-zone = (plist-get obj :mapZone)
                                               for metazone = (plist-get map-zone :_other)
                                               for golden-zone = (plist-get map-zone :_type)
                                               for territory = (plist-get map-zone :_territory)
                                               do (puthash metazone
                                                           (plist-put (gethash metazone table)
                                                                      (intern (concat ":" territory))
                                                                      golden-zone)
                                                           table)
                                               finally return table))
              (result (cl-loop
                       for (key value) on metazoneIds by #'cddr
                       for short-id = (substring (symbol-name key) 1)
                       for long-id = (plist-get value :_longId)
                       for map-zones = (gethash long-id metazone-golden-zone-territory)
                       do (cl-assert map-zones)
                       collect (list :short-id short-id :long-id long-id :map-zones map-zones))))
    result))

(defun my/world-clock--prepare-cldr-json-metazones ()
  "Prepare `my/world-clock--cldr-json-metazones'."
  (unless my/world-clock--cldr-json-metazones-index
    (setq my/world-clock--cldr-json-metazones-index (make-hash-table :test #'equal)))
  (unless my/world-clock--cldr-json-metazones
    (setq my/world-clock--cldr-json-metazones (my/world-clock--parse-cldr-json-metazones))
    (dolist (metazone my/world-clock--cldr-json-metazones)
      (puthash (plist-get metazone :short-id) metazone my/world-clock--cldr-json-metazones-index)
      (puthash (plist-get metazone :long-id) metazone my/world-clock--cldr-json-metazones-index))))

(defun my/world-clock--get-metazone (metazone)
  "Return the plist for METAZONE.

METAZONE can either be a short ID or a long ID."
  (my/world-clock--prepare-cldr-json-metazones)
  (gethash metazone my/world-clock--cldr-json-metazones-index))

(defun my/world-clock--get-preferred-zone (metazone alpha2)
  "Return the preferred zone of METAZONE for ALPHA2.

If the metazone has no preferred zone for ALPHA2,
the golden zone is returned.

Return nil if METAZONE cannot be found."
  (when-let* ((metazone-plist (my/world-clock--get-metazone metazone)))
    (let* ((map-zones (plist-get metazone-plist :map-zones))
           (golden-zone (plist-get map-zones :001))
           (preferred-zone (plist-get map-zones (intern (concat ":" alpha2)))))
      (or preferred-zone golden-zone))))

(defun my/world-clock--parse-cldr-json-metazone-mappings ()
  "Parse the file cldr-core/supplemental/metaZones.json at `my/world-clock-cldr-json-directory'.

If `my/world-clock-cldr-json-directory' is nil, return nil.
Otherwise return a list of plist.
See `my/world-clock--cldr-json-metazone-mappings'."
  (when-let* ((root (when my/world-clock-cldr-json-directory
                      (with-temp-buffer
                        (insert-file-contents (expand-file-name "./cldr-core/supplemental/metaZones.json" my/world-clock-cldr-json-directory))
                        (goto-char (point-min))
                        (let* ((result (json-parse-buffer :object-type 'plist
                                                          :array-type 'array)))
                          result))))
              (supplemental (plist-get root :supplemental))
              (metaZones (plist-get supplemental :metaZones))
              (metazoneInfo (plist-get metaZones :metazoneInfo))
              (timezones (plist-get metazoneInfo :timezone)))
    (let* (result)
      (cl-labels ((parse-time (s)
                    (let* ((decoded-time (iso8601-parse (string-replace " " "T" s))))
                      ;; Make it UTC
                      (setf (decoded-time-zone decoded-time) t)
                      ;; Mark DST information unavailable.
                      (setf (decoded-time-dst decoded-time) -1)
                      (time-convert (encode-time decoded-time) 'integer)))
                  (keys-to-string (keys)
                    (string-join (reverse (seq-map (lambda (key)
                                                     (substring (symbol-name key) 1))
                                                   keys))
                                 "/"))
                  (process-mappings (key value)
                    (push (list :name key
                                :mappings (cl-loop
                                           for obj across value
                                           for uses-metazone = (plist-get obj :usesMetazone)
                                           for metazone = (plist-get uses-metazone :_mzone)
                                           for from0 = (when-let* ((from (plist-get uses-metazone :_from)))
                                                         (parse-time from))
                                           for to0 = (when-let* ((to (plist-get uses-metazone :_to)))
                                                       (parse-time to))
                                           do (cl-assert metazone)
                                           collect (list :metazone metazone :from from0 :to to0)))
                          result))
                  (visit (plist parent-keys)
                    (cl-loop
                     for (key value) on plist by #'cddr
                     for keys = (cons key parent-keys)
                     when (listp value)
                     do (visit value keys)
                     when (arrayp value)
                     do (process-mappings (keys-to-string keys) value))))
        (visit timezones nil)
        result))))

(defun my/world-clock--prepare-cldr-json-metazone-mappings ()
  "Prepare `my/world-clock--cldr-json-metazone-mappings'."
  (unless my/world-clock--cldr-json-metazone-mappings-index
    (setq my/world-clock--cldr-json-metazone-mappings-index (make-hash-table :test #'equal)))
  (unless my/world-clock--cldr-json-metazone-mappings
    (setq my/world-clock--cldr-json-metazone-mappings (my/world-clock--parse-cldr-json-metazone-mappings))
    (dolist (plist my/world-clock--cldr-json-metazone-mappings)
      (let* ((name (plist-get plist :name)))
        (puthash name plist my/world-clock--cldr-json-metazone-mappings-index)
        (dolist (alias (plist-get (my/world-clock--get-bcp47-timezone name) :aliases))
          (puthash alias plist my/world-clock--cldr-json-metazone-mappings-index))))))

(defun my/world-clock--parse-cldr-json-metazone-mappings-reverse ()
  "Derive `my/world-clock--cldr-json-metazone-mappings-reverse'.

It is derived from `my/world-clock--cldr-json-metazone-mappings'
instead of parsing the file cldr-core/supplemental/metaZones.json again.

If `my/world-clock-cldr-json-directory' is nil, return nil."
  (my/world-clock--prepare-cldr-json-metazone-mappings)
  (let* ((table (make-hash-table :test #'equal))
         metazones)
    (dolist (plist my/world-clock--cldr-json-metazone-mappings)
      (dolist (mapping (plist-get plist :mappings))
        (let* ((metazone (plist-get mapping :metazone)))
          (unless (gethash metazone table)
            (push metazone metazones))
          (puthash metazone
                   (cons (list :name (plist-get plist :name)
                               :from (plist-get mapping :from)
                               :to (plist-get mapping :to))
                         (gethash metazone table))
                   table))))
    (seq-map (lambda (metazone)
               (list :metazone metazone :memberships (nreverse (gethash metazone table))))
             (nreverse metazones))))

(defun my/world-clock--prepare-cldr-json-metazone-mappings-reverse ()
  "Prepare `my/world-clock--cldr-json-metazone-mappings-reverse'."
  (unless my/world-clock--cldr-json-metazone-mappings-reverse-index
    (setq my/world-clock--cldr-json-metazone-mappings-reverse-index (make-hash-table :test #'equal)))
  (unless my/world-clock--cldr-json-metazone-mappings-reverse
    (setq my/world-clock--cldr-json-metazone-mappings-reverse (my/world-clock--parse-cldr-json-metazone-mappings-reverse))
    (dolist (plist my/world-clock--cldr-json-metazone-mappings-reverse)
      (let* ((metazone (plist-get plist :metazone)))
        (puthash metazone plist my/world-clock--cldr-json-metazone-mappings-reverse-index)
        (when-let* ((metazone-plist (my/world-clock--get-metazone metazone)))
          (puthash (plist-get metazone-plist :short-id) plist my/world-clock--cldr-json-metazone-mappings-reverse-index))))))

(defun my/world-clock--get-metazone-mappings (timezone)
  "Return the metazone mappings for TIMEZONE.

Return nil if not found."
  (my/world-clock--prepare-cldr-json-metazone-mappings)
  (when-let* ((timezone-plist (my/world-clock--get-plist timezone)))
    (gethash (plist-get timezone-plist :name) my/world-clock--cldr-json-metazone-mappings-index)))

(defun my/world-clock--get-metazone-of-timezone (time timezone)
  "Return the metazone long ID of TIMEZONE at TIME.

Return nil if TIMEZONE is not associated with a metazone."
  (when-let* ((metazone-mappings (my/world-clock--get-metazone-mappings timezone)))
    (cl-block loop
      (dolist (mapping (plist-get metazone-mappings :mappings))
        (let* ((from (plist-get mapping :from))
               (to (plist-get mapping :to))
               (metazone (plist-get mapping :metazone)))
          (cond
           ((and from to)
            (when (and (>= time from) (< time to))
              (cl-return-from loop metazone)))
           (from
            (when (>= time from)
              (cl-return-from loop metazone)))
           (to
            (when (< time to)
              (cl-return-from loop metazone)))
           (t
            (cl-return-from loop metazone))))))))

(defun my/world-clock--get-member-timezones-of-metazone (time metazone)
  "Return a list of member timezones of METAZONE at TIME.

The return value is a list of strings."
  (my/world-clock--prepare-cldr-json-metazone-mappings-reverse)
  (when-let* ((plist (gethash metazone my/world-clock--cldr-json-metazone-mappings-reverse-index)))
    (cl-loop
     for membership in (plist-get plist :memberships)
     for from = (plist-get membership :from)
     for to = (plist-get membership :to)
     when (and (or (null from) (>= time from))
               (or (null to) (< time to)))
     collect (plist-get membership :name))))

(defun my/world-clock--parse-cldr-json-timezone-localization ()
  "Parse the file cldr-dates-full/main/*/timeZoneNames.json at `my/world-clock-cldr-json-directory'.

If `my/world-clock-cldr-json-directory' is nil, return nil.
See `my/world-clock--cldr-json-timezone-localization'."
  (when-let* ((root (when my/world-clock-cldr-json-directory
                      (with-temp-buffer
                        (insert-file-contents (expand-file-name
                                               (format "./cldr-dates-full/main/%s/timeZoneNames.json" my/world-clock-cldr-json-locale)
                                               my/world-clock-cldr-json-directory))
                        (goto-char (point-min))
                        (let* ((result (json-parse-buffer :object-type 'plist
                                                          :array-type 'array)))
                          result))))
              (main (plist-get root :main))
              (locale (plist-get main (intern (concat ":" my/world-clock-cldr-json-locale))))
              (dates (plist-get locale :dates))
              (timeZoneNames (plist-get dates :timeZoneNames))
              (region-format (plist-get timeZoneNames :regionFormat))
              (region-format-daylight (plist-get timeZoneNames :regionFormat-type-daylight))
              (region-format-standard (plist-get timeZoneNames :regionFormat-type-standard))
              (fallback-format (plist-get timeZoneNames :fallbackFormat)))
    (let* (timezones)
      (cl-labels ((parse-names (plist)
                    (when plist
                      (let* ((generic (plist-get plist :generic))
                             (daylight (plist-get plist :daylight))
                             (standard (plist-get plist :standard)))
                        (when (or generic daylight standard)
                          (list :generic generic :daylight daylight :standard standard)))))
                  (keys-to-string (keys)
                    (string-join (reverse (seq-map (lambda (key)
                                                     (substring (symbol-name key) 1))
                                                   keys))
                                 "/"))
                  (visit (plist parent-keys)
                    (cl-loop
                     for (key value) on plist by #'cddr
                     for keys = (cons key parent-keys)
                     if (equal (plist-get value :_type) "zone")
                     do (let* ((long (parse-names (plist-get value :long)))
                               (short (parse-names (plist-get value :short)))
                               (exemplar-city (plist-get value :exemplarCity)))
                          (when (or long short exemplar-city)
                            (push (list :name (keys-to-string keys)
                                        :long long
                                        :short short
                                        :exemplar-city exemplar-city)
                                  timezones)))
                     else
                     do (visit value keys))))
        (visit (plist-get timeZoneNames :zone) nil)
        (list :region-format region-format
              :region-format-daylight region-format-daylight
              :region-format-standard region-format-standard
              :fallback-format fallback-format
              :timezones timezones
              :metazones (cl-loop
                          for (key value) on (plist-get timeZoneNames :metazone) by #'cddr
                          for long = (parse-names (plist-get value :long))
                          for short = (parse-names (plist-get value :short))
                          when (or long short)
                          collect (list :name (substring (symbol-name key) 1)
                                        :long long
                                        :short short)))))))

(defun my/world-clock--prepare-cldr-json-timezone-localization ()
  "Prepare `my/world-clock--cldr-json-timezone-localization'."
  (unless my/world-clock--cldr-json-timezone-localization-timezones-index
    (setq my/world-clock--cldr-json-timezone-localization-timezones-index (make-hash-table :test #'equal)))
  (unless my/world-clock--cldr-json-timezone-localization-metazones-index
    (setq my/world-clock--cldr-json-timezone-localization-metazones-index (make-hash-table :test #'equal)))
  (unless my/world-clock--cldr-json-timezone-localization
    (setq my/world-clock--cldr-json-timezone-localization (my/world-clock--parse-cldr-json-timezone-localization))
    (dolist (plist (plist-get my/world-clock--cldr-json-timezone-localization :timezones))
      (let* ((name (plist-get plist :name)))
        (puthash name plist my/world-clock--cldr-json-timezone-localization-timezones-index)
        (dolist (alias (plist-get (my/world-clock--get-bcp47-timezone name) :aliases))
          (puthash alias plist my/world-clock--cldr-json-timezone-localization-timezones-index))))
    (dolist (plist (plist-get my/world-clock--cldr-json-timezone-localization :metazones))
      (puthash (plist-get plist :name) plist my/world-clock--cldr-json-timezone-localization-metazones-index))))

(defun my/world-clock--get-exemplar-city-name (timezone)
  "Return the exemplar city name of TIMEZONE.

Return nil if TIMEZONE is not associated with a region."
  (my/world-clock--prepare-cldr-json-timezone-localization)
  (when-let* ((timezone-plist (my/world-clock--get-plist timezone))
              (canonicalized (plist-get timezone-plist :name))
              (alpha2 (plist-get timezone-plist :alpha2)))
    (let* ((localization (gethash canonicalized my/world-clock--cldr-json-timezone-localization-timezones-index))
           (exempler-city (plist-get localization :exemplar-city)))
      (or
       exempler-city
       (let* ((parts (split-string canonicalized "/"))
              (last-part (nth (1- (length parts)) parts))
              (underscore-to-space (string-replace "_" " " last-part)))
         underscore-to-space)))))

(defun my/world-clock--format-timezone--generic-non-location (time timezone)
  "Format TIMEZONE to the Generic non-location format at TIME.

The algorithm is a modified version of Step 4 of
https://unicode.org/reports/tr35/tr35-dates.html#Time_Zone_Goals
described below.

1. If long.generic for TIMEZONE exists, use it.
2. Otherwise, let
   TIMEZONE-ALPHA2 be the ISO 3166 alpha-2 code of TIMEZONE
   METAZONE be the metazone of TIMEZONE at TIME
3. If the member timezones of METAZONE at TIME are all from the same territory, use long.generic of METAZONE.
4. Otherwise, use fallbackFormat with {0} being the name of TIMEZONE-ALPHA2
                                      {1} being long.generic of METAZONE

Return nil if any of the above variables are nil."
  (my/world-clock--prepare-cldr-json-timezone-localization)
  (when-let* ((timezone-plist (my/world-clock--get-plist timezone))
              (canonicalized (plist-get timezone-plist :name)))
    (let* ((localization (gethash canonicalized my/world-clock--cldr-json-timezone-localization-timezones-index))
           (long-generic (plist-get (plist-get localization :long) :generic)))
      (or
       ;; Step 1
       long-generic
       ;; Step 2
       (when-let* ((timezone-alpha2 (plist-get timezone-plist :alpha2))
                   (metazone (my/world-clock--get-metazone-of-timezone time timezone))
                   (metazone-localization (gethash metazone my/world-clock--cldr-json-timezone-localization-metazones-index))
                   (metazone-long-generic (plist-get (plist-get metazone-localization :long) :generic)))
         ;; The member timezones are cldr-json timezone names,
         ;; so their territories are looked up via BCP47 instead of tzdata.
         (if (eql 1 (length (seq-uniq (seq-map (lambda (member)
                                                 (plist-get (my/world-clock--get-bcp47-timezone member) :alpha2))
                                               (my/world-clock--get-member-timezones-of-metazone time metazone)))))
             ;; Step 3
             metazone-long-generic
           ;; Step 4
           (when-let* ((territory-name (my/world-clock--get-short-territory-name timezone-alpha2))
                       (fallback-format (plist-get my/world-clock--cldr-json-timezone-localization :fallback-format)))
             (string-replace "{1}" metazone-long-generic
                             (string-replace "{0}" territory-name fallback-format)))))))))

(defun my/world-clock--format-timezone--generic-location (timezone)
  "Format TIMEZONE according to UTS #35 using the Generic Location format.

See Step 5 of https://unicode.org/reports/tr35/tr35-dates.html#Time_Zone_Goals

Return nil if the format does not apply to TIMEZONE.
For example, Etc/UTC is not associated with a location,
so the format does not apply to it."
  (my/world-clock--prepare-cldr-json-timezone-localization)
  (when-let* ((timezone-plist (my/world-clock--get-plist timezone))
              (alpha2 (plist-get timezone-plist :alpha2))
              (region-format (plist-get my/world-clock--cldr-json-timezone-localization :region-format))
              (location (if (my/world-clock--sole-timezone-in-region-p timezone)
                            (my/world-clock--get-short-territory-name alpha2)
                          (my/world-clock--get-exemplar-city-name timezone))))
    (string-replace "{0}" location region-format)))

(defun my/world-clock--cldr-json-day-of-week-to-emacs (day-of-week)
  "Convert DAY-OF-WEEK into an integer in Emacs convention."
  (pcase day-of-week
    ("mon" 1)
    ("tue" 2)
    ("wed" 3)
    ("thu" 4)
    ("fri" 5)
    ("sat" 6)
    ("sun" 0)
    (_ (error "Invalid day-of-week %S" day-of-week))))

(defun my/world-clock--weekends (alpha2)
  "Return a list containing the day of week that are weekends in ALPHA2.
Each element is an integer ranged from 0 to 6, with 0 being Sunday and 6 being Saturday.

If `my/world-clock-cldr-json-directory' is non-nil, cldr-json data is parsed and consulted.
Otherwise, always return (6 0)."
  (if (null my/world-clock-cldr-json-directory)
      (list 6 0)
    (unless my/world-clock--cldr-json-weekData-json
      (setq my/world-clock--cldr-json-weekData-json (my/world-clock--parse-cldr-json-weekData-json)))
    (let* ((supplemental (plist-get my/world-clock--cldr-json-weekData-json :supplemental))
           (week-data (plist-get supplemental :weekData))
           (weekend-start (plist-get week-data :weekendStart))
           (weekend-end (plist-get week-data :weekendEnd))
           (weekend-start-001 (plist-get weekend-start :001))
           (weekend-end-001 (plist-get weekend-end :001))
           (alpha2-key (intern (concat ":" alpha2)))
           (weekend-start-alpha2 (plist-get weekend-start alpha2-key))
           (weekend-end-alpha2 (plist-get weekend-end alpha2-key))
           (weekend-start-resolved (or weekend-start-alpha2 weekend-start-001))
           (weekend-end-resolved (or weekend-end-alpha2 weekend-end-001))
           (weekend-start-emacs (my/world-clock--cldr-json-day-of-week-to-emacs weekend-start-resolved))
           (weekend-end-emacs (my/world-clock--cldr-json-day-of-week-to-emacs weekend-end-resolved))
           (day-of-week weekend-start-emacs)
           result)
      ;; do-while loop
      (while (progn
               (push day-of-week result)
               (/= day-of-week weekend-end-emacs))
        (setq day-of-week (mod (1+ day-of-week) 7)))
      (nreverse result))))

(defun my/world-clock--weekday-p (day-of-week weekends)
  "Return non-nil if the modulo of DAY-OF-WEEK is not in WEEKENDS.

If WEEKENDS is nil, always return nil."
  (when weekends
    ;; We consider modulo so that the call site can write (1- day-of-week)
    (not (seq-contains-p weekends (mod day-of-week 7)))))

(defun my/world-clock--get-plist (timezone)
  "Return the plist for TIMEZONE."
  (my/world-clock--prepare-timezones)
  (gethash timezone my/world-clock--timezones-index))

(defun my/world-clock--prefix-p (prefix timezone)
  "Return non-nil if TIMEZONE starts with PREFIX."
  (let* ((prefix (format "%s/" prefix)))
    (not (not (string-match-p (rx string-start (literal prefix))
                              timezone)))))

(defun my/world-clock--continent-p (timezone)
  "Return non-nil if TIMEZONE is associated with a continent."
  (not (not (string-match-p (rx string-start
                                (or
                                 "Africa/"
                                 "America/"
                                 "Antarctica/"
                                 "Asia/"
                                 "Europe/"
                                 "Australia/"))
                            timezone))))

(defun my/world-clock--ocean-p (timezone)
  "Return non-nil if TIMEZONE is associated with an ocean."
  (not (not (string-match-p (rx string-start
                                (or
                                 "Pacific/"
                                 "Atlantic/"
                                 "Indian/"
                                 "Arctic/"))
                            timezone))))

(defun my/world-clock--etc-p (timezone)
  "Return non-nil if TIMEZONE starts with Etc/."
  (not (not (string-match-p (rx string-start "Etc/")
                            timezone))))

(defun my/world-clock--get-home-timezones (time home-timezone)
  "Return a list of timezones suitable for being home timezone at TIME with HOME-TIMEZONE."
  (my/world-clock--prepare-timezones)
  (let* ((timezones (seq-map (lambda (plist)
                               (plist-get plist :name))
                             my/world-clock--timezones))
         (timezones (seq-filter (lambda (timezone)
                                  (or (my/world-clock--continent-p timezone)
                                      (my/world-clock--ocean-p timezone)
                                      (my/world-clock--etc-p timezone)))
                                timezones))
         (timezones (my/world-clock--sort-timezones timezones time home-timezone)))
    (my/world-clock--add-home-to-list home-timezone timezones)))

(defun my/world-clock--get-alpha2-list ()
  "Return a list of distinct ISO 3166 alpha-2 code.

Timezones not associated with a region, like Etc/UTC, are excluded."
  (my/world-clock--prepare-timezones)
  (seq-uniq (delq nil (seq-map (lambda (plist) (plist-get plist :alpha2))
                               my/world-clock--timezones))))

(defun my/world-clock--canonicalize (timezone)
  "Return the canonical name of TIMEZONE.

Return TIMEZONE if it cannot be canonicalized."
  (let* ((plist (my/world-clock--get-plist timezone)))
    (or (plist-get plist :name) timezone)))

(defun my/world-clock--utc-offset (time timezone)
  "A variant of `current-time-zone' that always take TIME and TIMEZONE.
It returns the car of what `current-time-zone' returns.

This function caches its result with `my/world-clock--utc-offset-cache' and
`my/world-clock--utc-offset-cache-time'.

Clear the cache if a different TIME is passed to this function.
Given TIME is fixed, results of different TIMEZONE are cached."
  (unless my/world-clock--utc-offset-cache
    (setq-local my/world-clock--utc-offset-cache (make-hash-table :test #'equal)))
  (unless (equal time my/world-clock--utc-offset-cache-time)
    (clrhash my/world-clock--utc-offset-cache)
    (setq-local my/world-clock--utc-offset-cache-time time))
  (or (gethash timezone my/world-clock--utc-offset-cache)
      (puthash timezone
               (car (current-time-zone time timezone))
               my/world-clock--utc-offset-cache)))

(defun my/world-clock--diff (time home-timezone that-timezone)
  "Return the difference between HOME-TIMEZONE and THAT-TIMEZONE at TIME in number of seconds."
  (let* ((home-utc-offset (my/world-clock--utc-offset time home-timezone))
         (that-utc-offset (my/world-clock--utc-offset time that-timezone))
         (diff-in-seconds (- that-utc-offset home-utc-offset)))
    diff-in-seconds))

(defun my/world-clock--%z (time this-timezone that-timezone)
  "Return a string representing the difference between THIS-TIMEZONE and THAT-TIMEZONE at TIME.

This is similar to what `format-time-string' does between UTC and timezone for %z,
except that seconds are included when they are non-zero.
For example, Asia/Hong_Kong was +073642 from UTC before 1904.
The result is either 5 or 7 characters long."
  (let* ((diff-in-seconds (my/world-clock--diff time this-timezone that-timezone))
         (sign (if (< diff-in-seconds 0) -1 1))
         (diff-in-seconds (abs diff-in-seconds))
         (diff-in-minutes (/ diff-in-seconds 60))
         (diff-in-hours (/ diff-in-minutes 60))
         (diff-in-minutes (mod diff-in-minutes 60))
         (diff-in-seconds (mod diff-in-seconds 60)))
    (if (zerop diff-in-seconds)
        (format "%s%02d%02d"
                (if (< sign 0) "-" "+")
                diff-in-hours
                diff-in-minutes)
      (format "%s%02d%02d%02d"
              (if (< sign 0) "-" "+")
              diff-in-hours
              diff-in-minutes
              diff-in-seconds))))

(defun my/world-clock--alpha2-to-flag (alpha2)
  "Return the emoji flag for ALPHA2."
  (seq-into (seq-map (lambda (codepoint) (+ codepoint #x1f1e6 (- ?A))) alpha2) 'string))

(defun my/world-clock--decode-time (time utc-offset)
  "Decode TIME at UTC-OFFSET without switching time zones.

Only the first 7 fields (seconds, minutes, hours, day, month, year, day-of-week, _, _)
are meaningful.
The DST field is nil and the zone field is 0, regardless of the actual zone."
  ;; (decode-time time utc-offset)
  (decode-time (time-add time utc-offset) t))

(defun my/world-clock--solar-sunrise-sunset (time timezone)
  "Invoke `solar-sunrise-sunset' at TIME in TIMEZONE."
  (when-let* ((plist (my/world-clock--get-plist timezone))
              (latitude (plist-get plist :latitude))
              (longitude (plist-get plist :longitude))
              (offset-in-seconds (my/world-clock--utc-offset time timezone))
              (offset-in-minutes (/ offset-in-seconds 60))
              (decoded-time (my/world-clock--decode-time time offset-in-seconds))
              (year (decoded-time-year decoded-time))
              (month (decoded-time-month decoded-time))
              (day (decoded-time-day decoded-time))
              (date (list month day year)))
    (let* ((calendar-latitude latitude)
           (calendar-longitude longitude)
           (calendar-time-zone offset-in-minutes)
           (calendar-standard-time-zone-name "")
           (calendar-daylight-savings-starts nil)
           (calendar-daylight-savings-ends nil)
           (result (solar-sunrise-sunset date)))
      result)))

(defun my/world-clock--decoded-time-to-hms (decoded-time)
  "Return a float representing the local time of DECODED-TIME."
  (let* ((hour (decoded-time-hour decoded-time))
         (minute (decoded-time-minute decoded-time))
         (second (decoded-time-second decoded-time))
         (hms (+ hour (/ minute 60.0) (/ second 3600.0))))
    hms))

(defun my/world-clock--daylight-p (time timezone)
  "Return non-nil if it is daylight at TIME in TIMEZONE."
  (when-let* ((offset-in-seconds (my/world-clock--utc-offset time timezone))
              (decoded-time (my/world-clock--decode-time time offset-in-seconds))
              (sunrise-sunset (my/world-clock--solar-sunrise-sunset time timezone))
              (hms (my/world-clock--decoded-time-to-hms decoded-time))
              (sunrise (car (nth 0 sunrise-sunset)))
              (sunset (car (nth 1 sunrise-sunset)))
              (daylight-length (nth 2 sunrise-sunset)))
    (cond
     ;; When this day has sunrise and sunset
     ((and sunrise sunset)
      ;; It is daylight when the current time is after sunrise and before sunset.
      (and (>= hms sunrise) (< hms sunset)))
     ;; When this day has only sunrise (maybe the sunset is on the next day)
     (sunrise
      ;; It is daylight when the current time is after sunrise.
      (>= hms sunrise))
     ;; When this day has only sunset (maybe the sunrise was on the previous day)
     (sunset
      ;; It is daylight when the current time is before sunset.
      (< hms sunset))
     ;; Otherwise, it could be a polar day or polar night.
     (t
      ;; It is daylight when the daylight length is all day.
      (string= daylight-length "24:00")))))

(defun my/world-clock--min-max-utc-offsets (time timezone)
  "Return a 2-element list.

Calculate the UTC offset in TIMEZONE on the first day of
each of the 12 months after TIME's month.
TIME's month is not included.

The first element is the minimum value of these offsets,
while the second element is the maximum value."
  (unless my/world-clock--min-max-utc-offsets-cache
    (setq-local my/world-clock--min-max-utc-offsets-cache (make-hash-table :test #'equal)))
  (let* ((decoded-time (my/world-clock--decode-time time (my/world-clock--utc-offset time timezone)))
         (year (decoded-time-year decoded-time))
         (month (decoded-time-month decoded-time))
         (key (list year month timezone)))
    (or
     (gethash key my/world-clock--min-max-utc-offsets-cache)
     (puthash key
              (let* ((offsets (seq-map (lambda (increment-by)
                                         ;; Pass timezone as t to mean UTC.
                                         (let* ((decoded-time (list 0 0 0 1 (+ month increment-by) year nil -1 t))
                                                (time (encode-time decoded-time))
                                                (result (current-time-zone time timezone))
                                                (offset (car result)))
                                           offset))
                                       (number-sequence 1 12 1)))
                     (min (seq-min offsets))
                     (max (seq-max offsets)))
                (list min max))
              my/world-clock--min-max-utc-offsets-cache))))

(defun my/world-clock--dst-state (time timezone)
  "Return an estimated DST state at TIME in TIMEZONE.

Return nil if TIMEZONE does not observe DST in the coming 12 months.
Return the symbol on if TIMEZONE observes DST and DST is in effect at TIME.
Return the symbol off if TIMEZONE observes DST and DST is not in effect at TIME.

This function does not look at the exact rules of TZDB,
and relies on sampling to give an estimate."
  (let* ((offset-at-time (my/world-clock--utc-offset time timezone))
         ;; The min and max offsets in the next 12 months.
         (result (my/world-clock--min-max-utc-offsets time timezone))
         (min-offset (min offset-at-time (nth 0 result)))
         (max-offset (max offset-at-time (nth 1 result))))
    (cond
     ;; No offset difference in the coming 12 months.
     ;; Assume this timezone does not observe DST.
     ((eql min-offset max-offset)
      nil)
     ;; The offset at TIME is greater than min.
     ;; It means the time on wall clock at TIME is ahead.
     ;; In other words, DST is in effect.
     ((> offset-at-time min-offset)
      'on)
     ;; Otherwise, DST is not in effect.
     (t
      'off))))

(defun my/world-clock--dst-next-change (time timezone)
  "Search forward from TIME in TIMEZONE for the next change in DST.

Search forward at most 52 weeks.
Accurate to a second.

Return a time value if found, otherwise nil."
  (cl-labels ((offset-at (t)
                (car (current-time-zone t timezone))))
    (cl-block loop
      (let* ((time (time-convert time 'integer))
             (offset-at-time (offset-at time)))
        (dotimes (i 52)
          (let* ((t1 (time-convert (time-add time (days-to-time (* (1+ i) 7))) 'integer))
                 (offset-at-t1 (offset-at t1)))
            (when (/= offset-at-t1 offset-at-time)
              (let* ((low time)
                     (high t1)
                     needle
                     offset-at-needle)
                (while (progn
                         (setq needle (floor (+ low high) 2))
                         (and (< low high) (/= needle low)))
                  (setq offset-at-needle (offset-at needle))
                  (cond
                   ((eql offset-at-needle offset-at-time)
                    (setq low needle))
                   ((eql offset-at-needle offset-at-t1)
                    (setq high needle))
                   (t
                    (error "DST change within a week is unsupported"))))
                (let* ((offset-at-low (offset-at low))
                       (offset-at-high (offset-at high)))
                  (when (/= offset-at-low offset-at-time)
                    (cl-return-from loop low))
                  (when (/= offset-at-high offset-at-time)
                    (cl-return-from loop high)))))))))))

(defun my/world-clock--dst-previous-change (time timezone)
  "Search backward from TIME in TIMEZONE for the previous change in DST.

Search backward at most 52 weeks.
Accurate to a second.

Return a time value if found, otherwise nil."
  (cl-labels ((offset-at (t)
                (car (current-time-zone t timezone))))
    (cl-block loop
      (let* ((time (time-convert time 'integer))
             (offset-at-time (offset-at time)))
        (dotimes (i 52)
          (let* ((t1 (time-convert (time-add time (days-to-time (* (1+ i) -7))) 'integer))
                 (offset-at-t1 (offset-at t1)))
            (when (/= offset-at-t1 offset-at-time)
              (let* ((low t1)
                     (high time)
                     needle
                     offset-at-needle)
                (while (progn
                         (setq needle (floor (+ low high) 2))
                         (and (< low high) (/= needle low)))
                  (setq offset-at-needle (offset-at needle))
                  (cond
                   ((eql offset-at-needle offset-at-t1)
                    (setq low needle))
                   ((eql offset-at-needle offset-at-time)
                    (setq high needle))
                   (t
                    (error "DST change within a week is unsupported"))))
                (cl-return-from loop high)))))))))

(defun my/world-clock--tooltip (time timezone)
  "Return a description for TIMEZONE at TIME.

The first line is TIMEZONE.
The next line is the last DST change if it has any.
The next line is the next DST change if it has any."
  ;; Do not use %Z because it does not support formatting
  ;; a time with the previous offset.
  ;; For example, in "2026-03-08 Sun 02:00 PST -> 03:00 PDT",
  ;; we cannot ask format-time-string to give "02:00 PST"
  ;; because at the moment, it is actually "PDT" instead of "PST".
  (cl-labels ((format-time (time offset-and-label)
                (let* ((offset (car offset-and-label))
                       (label (cadr offset-and-label))
                       (hh-mm (format-time-string "%H:%M" time offset)))
                  (if label
                      (format "%s %s" hh-mm label)
                    (format-time-string "%H:%M" time offset))))
              (format-date (time offset-and-label)
                (format-time-string "%F %a" time (car offset-and-label)))
              (format-tooltip (format-string time from-offset-and-label to-offset-and-label)
                (when time
                  (let* ((time-from (format-time time from-offset-and-label))
                         (time-to (format-time time to-offset-and-label))
                         (date-from (format-date time from-offset-and-label))
                         (date-to (format-date time to-offset-and-label))
                         (change (if (string= date-from date-to)
                                     (format "%s %s -> %s" date-from time-from time-to)
                                   (format "%s %s -> %s %s" date-from time-from date-to time-to))))
                    (format format-string change)))))
    (let* ((previous-change-tooltip (when-let* ((previous-change-at (my/world-clock--dst-previous-change time timezone))
                                                (current-offset-and-label (current-time-zone time timezone))
                                                (previous-offset-and-label (current-time-zone (time-add previous-change-at -1) timezone)))
                                      (format-tooltip "Last DST change: %s" previous-change-at previous-offset-and-label current-offset-and-label)))
           (next-change-tooltip (when-let* ((next-change-at (my/world-clock--dst-next-change time timezone))
                                            (current-offset-and-label (current-time-zone time timezone))
                                            (next-offset-and-label (current-time-zone next-change-at timezone)))
                                  (format-tooltip "Next DST change: %s" next-change-at current-offset-and-label next-offset-and-label))))
      (string-join (remq nil
                         (list timezone
                               previous-change-tooltip
                               next-change-tooltip))
                   "\n"))))

(defun my/world-clock--dst-label-for-state (dst-state)
  "Return a label for DST-STATE.

If dst-state is on, return the string DST.
If dst-state is off, return the string std.
Otherwise, return a string of 3 spaces."
  (pcase dst-state
    ('on "DST")
    ('off "std")
    (_ "   ")))

(defun my/world-clock--iso8601-time-to-hms (s)
  "Convert ISO8601 time string S into a float."
  (let* ((decoded-time (iso8601-parse-time s))
         (hms (my/world-clock--decoded-time-to-hms decoded-time)))
    hms))

(defun my/world-clock--within-business-hours-p (time timezone)
  "Return non-nil if TIME is within business hours in TIMEZONE.

See `my/world-clock-business-hours'."
  (let* ((plist (my/world-clock--get-plist timezone))
         (alpha2 (plist-get plist :alpha2))
         (weekends (and alpha2 (my/world-clock--weekends alpha2)))
         (offset (my/world-clock--utc-offset time timezone))
         (decoded-time (my/world-clock--decode-time time offset))
         (day-of-week (decoded-time-weekday decoded-time))
         (time-hms (my/world-clock--decoded-time-to-hms decoded-time))
         (business-hours-start (nth 0 my/world-clock-business-hours))
         (business-hours-end (nth 1 my/world-clock-business-hours))
         (business-hours-start-hms (my/world-clock--iso8601-time-to-hms business-hours-start))
         (business-hours-end-hms (my/world-clock--iso8601-time-to-hms business-hours-end)))
    (cond
     ;; Normal business hours
     ((< business-hours-start-hms business-hours-end-hms)
      ;; It must be a weekday.
      (and (my/world-clock--weekday-p day-of-week weekends)
           ;; START <= T < END
           (>= time-hms business-hours-start-hms)
           (< time-hms business-hours-end-hms)))
     ;; Overnight business hours
     ((< business-hours-end-hms business-hours-start-hms)
      (or
       ;; It must be a weekday
       (and (my/world-clock--weekday-p day-of-week weekends)
            ;; and T >= START
            (>= time-hms business-hours-start-hms))
       ;; Yesterday must be a weekday
       (and (my/world-clock--weekday-p (1- day-of-week) weekends)
            ;; and T < END
            (< time-hms business-hours-end-hms))))
     ;; No business hours
     (t
      nil))))

(defun my/world-clock--business-hours-face (time timezone)
  "Return a face if TIME is within business hours in TIMEZONE."
  (when (my/world-clock--within-business-hours-p time timezone)
    'diff-added))

(defun my/world-clock--flag (plist)
  "Return a flag for PLIST."
  (let* ((alpha2 (plist-get plist :alpha2)))
    (or
     (and alpha2 (my/world-clock--alpha2-to-flag alpha2))
     "🏴")))

(defun my/world-clock--daylight-face (plist time)
  "Return the face for PLIST at TIME.

If PLIST is nil, return nil.
If PLIST has no coordinates, return nil."
  (when-let* ((timezone (plist-get plist :name))
              (_ (plist-get plist :latitude)))
    (if (my/world-clock--daylight-p time timezone)
        'font-lock-warning-face
      'font-lock-comment-face)))

(defun my/world-clock--set-face (s face)
  "Set text property `my/world-clock--face' to FACE on S."
  (propertize s 'my/world-clock--face face 'face face))
(defun my/world-clock--set-business-hours-face (s face)
  "Set text property `my/world-clock--business-hours-face' to FACE on S."
  (propertize s 'my/world-clock--business-hours-face face))

(defun my/world-clock--label (timezone time home-timezone)
  "Return a label for TIMEZONE at TIME with HOME-TIMEZONE."
  (let* ((plist (my/world-clock--get-plist timezone))
         (flag (my/world-clock--flag plist))
         (daylight-face (my/world-clock--daylight-face plist time))
         (dst-state (my/world-clock--dst-state time timezone))
         (dst-state-label (my/world-clock--dst-label-for-state dst-state))
         (business-hours-face (my/world-clock--business-hours-face time timezone))
         (timezone-display-name (or (my/world-clock--format-timezone--generic-non-location time timezone)
                                    (my/world-clock--format-timezone--generic-location timezone)
                                    timezone)))
    (propertize
     (format "%-7s UTC%-7s %s %s %s"
             (if (string= timezone home-timezone)
                 (format "%5s" "Home")
               (my/world-clock--%z time home-timezone timezone))
             (my/world-clock--%z time "Etc/UTC" timezone)
             dst-state-label
             flag
             (my/world-clock--set-business-hours-face
              (my/world-clock--set-face timezone-display-name daylight-face)
              business-hours-face))
     'help-echo
     (lambda (_window _object _pos)
       (my/world-clock--tooltip time timezone)))))

(defun my/world-clock--completing-read-label-function-for-timezone (time home-timezone)
  "Return a function for labeling timezone at TIME with HOME-TIMEZONE."
  (lambda (timezone)
    (let* ((plist (my/world-clock--get-plist timezone))
           (flag (my/world-clock--flag plist))
           (daylight-face (my/world-clock--daylight-face plist time))
           (aliases (plist-get plist :aliases))
           (offset-from-home (if (string= timezone home-timezone)
                                 (format "%5s" "Home")
                               (my/world-clock--%z time home-timezone timezone)))
           (offset-from-utc (my/world-clock--%z time "Etc/UTC" timezone)))
      (if aliases
          (format "%-7s UTC%-7s %s %s (%s)"
                  offset-from-home
                  offset-from-utc
                  flag
                  (my/world-clock--set-face timezone daylight-face)
                  (my/world-clock--set-face (string-join aliases " ") daylight-face))
        (format "%-7s UTC%-7s %s %s"
                offset-from-home
                offset-from-utc
                flag
                (my/world-clock--set-face timezone daylight-face))))))

(defun my/world-clock--completing-read-label-function-for-alpha2 (alpha2)
  "Return a label for ALPHA2."
  (my/world-clock--prepare-timezones)
  (let* ((plist (seq-find (lambda (plist)
                            (string= alpha2 (plist-get plist :alpha2)))
                          my/world-clock--timezones))
         (territory (my/world-clock--get-territory alpha2))
         (territory-name (plist-get territory :name))
         (territory-short-name (plist-get territory :short-name))
         (alpha2-name (plist-get plist :alpha2-name)))
    (cond
     (territory-short-name
      (format "%s %s %s (%s)"
              (my/world-clock--alpha2-to-flag alpha2)
              alpha2
              (or territory-name alpha2-name)
              territory-short-name))
     (t
      (format "%s %s %s"
              (my/world-clock--alpha2-to-flag alpha2)
              alpha2
              (or territory-name alpha2-name))))))

(defun my/world-clock--completing-read (prompt strings label-function)
  "Invoke `completing-read' with PROMPT and STRINGS.

LABEL-FUNCTION is function that takes the element in STRINGS and return a string.

Return an element in STRINGS or nil."
  (let* ((collection (seq-map label-function strings))
         (alist (seq-mapn #'cons collection strings))
         (selected (completing-read prompt collection nil t)))
    (cdr (assoc selected alist))))

(defun my/world-clock--eldoc-function (_callback &rest _)
  "Return the text property help-echo at point for ElDoc."
  (let ((help (get-char-property (point) 'help-echo)))
    (when (functionp help)
      (setq help (funcall help (selected-window) (current-buffer) (point))))
    (when (stringp help)
      help)))

(defun my/world-clock--setup-eldoc ()
  "Show the text property help-echo of the label with ElDoc."
  (add-hook 'eldoc-documentation-functions #'my/world-clock--eldoc-function nil t)
  (eldoc-mode 1))

;;;; Mode setup
(with-eval-after-load 'time
  (add-hook 'world-clock-mode-hook #'my/world-clock--setup-eldoc)
  (keymap-set world-clock-mode-map "." #'my/world-clock-now)
  (keymap-set world-clock-mode-map "b" #'my/world-clock-backward-15-minutes)
  (keymap-set world-clock-mode-map "f" #'my/world-clock-forward-15-minutes)
  (keymap-set world-clock-mode-map "C-b" #'my/world-clock-backward-1-hour)
  (keymap-set world-clock-mode-map "C-f" #'my/world-clock-forward-1-hour)
  (keymap-set world-clock-mode-map "j" #'my/world-clock-jump)
  (advice-add #'world-clock :before #'my/world-clock--before)
  (advice-add #'world-clock-display :around #'my/world-clock-display--around)
  (advice-add #'world-clock-display :after #'my/world-clock-display--after)
  (eldoc-add-command #'my/world-clock-now
                     #'my/world-clock-forward-15-minutes
                     #'my/world-clock-backward-15-minutes
                     #'my/world-clock-forward-1-hour
                     #'my/world-clock-backward-1-hour
                     #'my/world-clock-jump))

;;;; Configuration
(setq
 ;; Turn off the timer
 world-clock-timer-enable nil
 ;; 2006-01-02 Mon 15:04
 world-clock-time-format "%F %a %H:%M"
 my/world-clock-cldr-json-directory "~/.nix-profile/share/cldr-json/48.2.3"
 my/world-clock-zoneinfo-list
 '("Asia/Hong_Kong"
   "Asia/Tokyo"
   "Asia/Seoul"
   "Asia/Bangkok"
   "Asia/Kolkata"
   "Asia/Karachi"
   "Asia/Dhaka"
   "Asia/Tehran"
   "Asia/Jerusalem"
   "Asia/Dubai"
   "Australia/Sydney"
   "Pacific/Auckland"
   "Africa/Nairobi"
   "Africa/Johannesburg"
   "Africa/Lagos"
   "Europe/London"
   "Europe/Amsterdam"
   "Etc/UTC"
   "America/New_York"
   "America/Chicago"
   "America/Phoenix"
   "America/Denver"
   "America/Los_Angeles"
   "America/Anchorage"
   "Pacific/Honolulu"
   "America/Toronto"
   "America/Vancouver"
   "America/Mexico_City"
   "America/Bogota"
   "America/Sao_Paulo"))

(provide 'init-world-clock-mode)
;;; init-world-clock-mode.el ends here
