;;; init-tempel.el --- init-tempel.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'calendar)

(defun my/tempel-templates-global ()
  "Return a list of global Tempel templates."
  (let* ((date (calendar-current-date))
         (today (my/calendar-gregorian-iso8601-date-string date))
         (yesterday (my/calendar-gregorian-iso8601-date-string (my/calendar-gregorian-add date :days -1)))
         (tomorrow (my/calendar-gregorian-iso8601-date-string (my/calendar-gregorian-add date :days 1)))
         (thisweek (my/calendar-gregorian-iso8601-week-string date))
         (lastweek (my/calendar-gregorian-iso8601-week-string (my/calendar-gregorian-add date :weeks -1)))
         (nextweek (my/calendar-gregorian-iso8601-week-string (my/calendar-gregorian-add date :weeks 1))))
    `((today
       ,today
       :ann ,today
       :doc ,today)
      (yesterday
       ,yesterday
       :ann ,yesterday
       :doc ,yesterday)
      (tomorrow
       ,tomorrow
       :ann ,tomorrow
       :doc ,tomorrow)
      (thisweek
       ,thisweek
       :ann ,thisweek
       :doc ,thisweek)
      (lastweek
       ,lastweek
       :ann ,lastweek
       :doc ,lastweek)
      (nextweek
       ,nextweek
       :ann ,nextweek
       :doc ,nextweek))))

(defun my/tempel-templates-elisp ()
  "Return a list of Elisp Tempel templates."
  (let* ((file (file-name-base (buffer-file-name))))
    `((elispfeature
       ";;; " ,file ".el --- " ,file ".el -*- lexical-binding: t -*-" n
       ";;; Commentary:" n
       ";;; Code:" n
       n
       q
       n
       n
       "(provide '" ,file ")" n
       ";;; " ,file ".el ends here" n
       :ann "Elisp file header"
       :doc "Elisp file header"))))

(setq
 tempel-template-sources
 '(my/tempel-templates-global))
(add-hook 'emacs-lisp-mode-hook (lambda ()
                                  (add-hook 'tempel-template-sources 'my/tempel-templates-elisp nil t)))

(keymap-global-set "C-c k" #'tempel-expand)
(with-eval-after-load 'tempel
  (keymap-set tempel-map "TAB" #'tempel-next)
  (keymap-set tempel-map "<backtab>" #'tempel-previous)
  (keymap-set tempel-map "S-TAB" #'tempel-previous))

(provide 'init-tempel)
;;; init-tempel.el ends here
