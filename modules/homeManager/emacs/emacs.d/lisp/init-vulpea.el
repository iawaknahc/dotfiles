;;; init-vulpea.el --- init-vulpea.el -*- lexical-binding: t -*-
;;; Commentary:
;;
;; vulpea has 2 main entrypoints, namely `vulpea-find' and `vulpea-insert'.
;; `vulpea-find' is bound in the global keymap.
;; The functionality of `vulpea-insert' is re-implemented as a custom CAPF.
;;
;;; Code:

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
 vulpea-db-parse-method 'single-temp-buffer

 vulpea-create-default-template (list :file-name "${title}.org")

 ;; Prevent typing the word "org" from matching all notes.
 ;; It is because "org_" is used as the prefix of all IDs.
 vulpea-select-match-ids nil
 ;; Show "Filename -> Parent Heading -> Note Title" for heading notes.
 vulpea-select-describe-fn #'vulpea-select-describe-outline-full)

(vulpea-db-autosync-mode 1)

;; `vulpea-find' is used to open notes or create a new note.
(keymap-global-set "M-o" #'vulpea-find)

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

(provide 'init-vulpea)
;;; init-vulpea.el ends here
