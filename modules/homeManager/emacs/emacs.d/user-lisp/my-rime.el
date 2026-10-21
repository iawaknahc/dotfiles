;;; my-rime.el --- my-rime.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'cl-lib)

(defcustom my/rime-user-directory nil
  "The path to Rime user directory."
  :type 'directory
  :group 'my/rime)

(defcustom my/rime-cangjie-dict-yaml nil
  "The path to a Cangjie dictionary in YAML format."
  :type 'file
  :group 'my/rime)

(defconst my/rime-cangjie-radical-mapping
  '("abcdefghijklmnopqrstuvwxyz" "日月金木水火土竹戈十大中一弓人心手口尸廿山女田難卜符")
  "The mapping from ASCII lowercase characters to Cangjie radicals.")

(defvar my/rime--cangjie-index nil
  "Hash table from character to its composition.")

(defvar my/rime--cangjie-radical-index nil
  "Hash table from ASCII lowercase character to Cangjie radical.")

;;;###autoload
(defun my/rime--ascii-to-radical (ascii)
  "Convert ASCII lowercase character to Cangjie radical."
  (unless my/rime--cangjie-radical-index
    (setq my/rime--cangjie-radical-index (make-hash-table :test #'equal))
    (seq-mapn (lambda (ascii radical)
                (puthash ascii radical my/rime--cangjie-radical-index))
              (nth 0 my/rime-cangjie-radical-mapping) (nth 1 my/rime-cangjie-radical-mapping)))
  (apply #'string (seq-map (lambda (ascii)
                             (gethash ascii my/rime--cangjie-radical-index))
                           ascii)))

;;;###autoload
(defun my/rime-cangjie-lookup (str)
  "Look up the Cangjie composition of each character in STR.

Return a list of compositions.
A composition is 3-element list.
The first element is the character itself.
The second element is the composition in ASCII lowercase characters.
The third element is the composition in Cangjie radicals."
  (unless my/rime--cangjie-index
    (setq my/rime--cangjie-index (make-hash-table :test #'equal))
    (when (and my/rime-user-directory my/rime-cangjie-dict-yaml)
      (with-temp-buffer
        (insert-file-contents (expand-file-name my/rime-cangjie-dict-yaml my/rime-user-directory))
        (goto-char (point-min))
        ;; Fast forward to the line where the mapping begins.
        (when (re-search-forward (rx line-start "..." line-end) nil t)
          (while (re-search-forward (rx line-start (group-n 1 (* (not "\t"))) "\t" (group-n 2 (* (in "a-z")))) nil t)
            (let* ((character (match-string-no-properties 1))
                   (composition (match-string-no-properties 2)))
              ;; Ordinary compositions never start with z and x.
              (unless (or (string-prefix-p "z" composition) (string-prefix-p "x" composition))
                (puthash character composition my/rime--cangjie-index))))))))
  (cl-loop
   for codepoint across str
   for character = (string codepoint)
   for ascii = (gethash character my/rime--cangjie-index)
   if ascii
   collect (list character ascii (my/rime--ascii-to-radical ascii))))

(provide 'my-rime)
;;; my-rime.el ends here
