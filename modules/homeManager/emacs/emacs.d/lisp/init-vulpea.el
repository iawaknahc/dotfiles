;;; init-vulpea.el --- init-vulpea.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; vulpea has 2 main entrypoints, namely `vulpea-find' and `vulpea-insert'.
;; `vulpea-find' is bound in the global keymap.
;; The functionality of `vulpea-insert' is re-implemented as a custom CAPF.
;;
;;; Code:

(require 'calendar)

;;;; Options
(setq
 vulpea-db-sync-directories (list "~/org/")
 vulpea-default-notes-directory "~/org/"

 ;; Use fswatch instead of polling to watch external changes.
 vulpea-db-sync-external-method 'fswatch
 ;; Fully async indexing.
 vulpea-db-async-extraction 'full
 ;; Do not index links without square brackets.
 vulpea-db-index-plain-links nil
 ;; Skip `org-mode-hook' while indexing.
 ;; See also `vulpea-ui-fast-parse'.
 vulpea-db-parse-method 'single-temp-buffer
 ;; Skip `org-mode-hook' while parsing.
 ;; See also `vulpea-db-parse-method'.
 vulpea-ui-fast-parse t

 vulpea-create-default-template `(
                                  :file-name "${title}.org"
                                  :properties (("CREATED" . "%<<%Y-%m-%d %a %H:%M>>")))

 ;; Prevent typing the word "org" from matching all notes.
 ;; It is because "org_" is used as the prefix of all IDs.
 vulpea-select-match-ids nil
 ;; Show "Filename -> Parent Heading -> Note Title" for heading notes.
 vulpea-select-describe-fn #'vulpea-select-describe-outline-full)

;;;; Turn on auto sync
(vulpea-db-autosync-mode 1)

;;;; Validate notes against schema via flymake.
(add-hook 'org-mode-hook #'vulpea-schema-flymake-mode)

(defun my/vulpea-load-schema-in-org-directory ()
  "Use `load-file' to load the file local-schemas.el in `org-directory'."
  (when-let* ((_ org-directory)
              (schema-file (expand-file-name "local-schemas.el" org-directory))
              (_ (file-readable-p schema-file)))
    (load-file schema-file)
    (message "Loaded schema file %S in org-directory %S" schema-file org-directory)))
(add-hook 'after-init-hook #'my/vulpea-load-schema-in-org-directory)

;;;; Keymap
;; `vulpea-find' is used to open notes or create a new note.
(keymap-global-set "C-c o" #'vulpea-find)

;;;; CAPF
;; Re-implement `vulpea-insert' as a custom CAPF.
(defconst my/vulpea-insert-capf--re (rx "[[id:" (group-n 1 (* (not (in "][")))) "]]")
  "The regexp to define BEG and END.")

(defun my/vulpea-insert-capf--collection ()
  "The completion table for `vulpea-insert'."
  ;; Respect `vulpea-find-default-candidates-source'.
  (let* ((notes (funcall vulpea-find-default-candidates-source))
         ;; Respect `vulpea-select-describe-fn'.
         (alist (seq-map (lambda (note) (vulpea-select-describe note)) notes)))
    (vulpea-select--completion-table alist)))

(defun my/vulpea-insert-capf ()
  "The completion-at-point-function for `vulpea-insert'."
  (when (org-in-regexp my/vulpea-insert-capf--re)
    (let* ((beg (match-beginning 1))
           (end (match-end 1)))
      (when (<= beg (point) end)
        (list
         beg
         end
         (completion-table-dynamic (lambda (_) (my/vulpea-insert-capf--collection)))
         :exclusive 'no
         ;; On exit the completion, delete the candidate string, and insert the ID link and the note title.
         :exit-function (lambda (candidate _status)
                          (when-let* ((note-id (get-text-property 0 'vulpea-note-id candidate))
                                      ;; FIXME: Make use of https://github.com/d12frosted/vulpea/issues/436
                                      (note (vulpea-db-get-by-id note-id))
                                      (note-title (vulpea-note-title note)))
                            (delete-char (- (length candidate)))
                            (insert note-id "][" note-title))))))))

;;;; Integration with calendar
(defun my/vulpea--note-get-date (note name)
  "Get a Gregorian date from NOTE at meta NAME.

Return nil if NAME is unavailable.
Return (MONTH DAY nil) if YEAR is 1583.
Return (MONTH DAY YEAR) otherwise."
  (when-let* ((value (vulpea-note-meta-get note name))
              (decoded-time (org-parse-time-string value))
              (year (nth 5 decoded-time))
              (month (nth 4 decoded-time))
              (day (nth 3 decoded-time)))
    (list month day (if (eql year 1583) nil year))))

(defun my/vulpea-holiday-birth-and-death ()
  "A holiday expression that fetches contacts from the vulpea database."
  (let* ((notes (vulpea-db-query (lambda (note)
                                   (and (vulpea-note-tagged-any-p note "contact")
                                        (or (vulpea-note-meta-get note "birthday")
                                            (vulpea-note-meta-get note "death_date"))))))
         (persons (seq-map (lambda (note)
                             (let* ((name (vulpea-note-title note))
                                    (birthday (my/vulpea--note-get-date note "birthday"))
                                    (death-date (my/vulpea--note-get-date note "death_date")))
                               (list :name name :birthday birthday :death-date death-date)))
                           notes))
         (holidays (seq-mapcat (lambda (person)
                                 (my/holiday-birth-and-death
                                  (plist-get person :name)
                                  (plist-get person :birthday)
                                  (plist-get person :death-date)))
                               persons)))
    (my/holiday-sort holidays)))

;;;; Integration with MapLibre GL
(defun my/vulpea-location-to-geojson-feature (note)
  "Convert NOTE into a GeoJSON Feature."
  `(:type
    "Feature"
    :geometry
    (:type
     "Point"
     :coordinates
     [,(vulpea-note-meta-get note "longitude" 'number)
      ,(vulpea-note-meta-get note "latitude" 'number)])
    :properties
    (:title
     ,(vulpea-note-title note)
     :kind
     ,(vulpea-note-meta-get note "location_kind"))))

(defun my/vulpea-geojson ()
  "Convert notes into a GeoJSON FeatureCollection."
  (let* ((notes (vulpea-db-query (lambda (note)
                                   (vulpea-schema-applies-p note 'location))))
         (features (seq-map #'my/vulpea-location-to-geojson-feature notes))
         (features (seq-into features 'vector))
         (feature-collection `(:type
                               "FeatureCollection"
                               :features
                               ,features)))
    (json-serialize feature-collection)))

(provide 'init-vulpea)
;;; init-vulpea.el ends here
