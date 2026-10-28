;;; init-simple-httpd.el --- init-simple-httpd.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'simple-httpd)

(setq
 ;; Bind to loopback interface only.
 httpd-host "127.0.0.1"
 httpd-port 8080
 ;; No public root.
 httpd-root nil
 ;; Do not serve `httpd-root'.
 httpd-serve-files nil
 ;; No directory listings.
 httpd-listings nil
 ;; Allow the use of httpd/ functions.
 httpd-servlets t)

;; Teach it about .mjs
(push (cons "mjs" "text/javascript") httpd-mime-types)

;; This macro defines `httpd/maplibre/env.json'.
(httpd-servlet maplibre/env.json "application/json" ()
  (insert (json-serialize `(
                            :key
                            ,(funcall (plist-get (car-safe (auth-source-search :host "maptiler.com")) :secret))
                            :latitude ,calendar-latitude
                            :longitude ,calendar-longitude
                            :zoom 11))))

(httpd-servlet maplibre/geojson.json "application/json" ()
  (insert (my/vulpea-geojson)))

;; This macro defines `httpd/maplibre'.
(httpd-file-servlet maplibre (expand-file-name "maplibre/" user-emacs-directory))

(provide 'init-simple-httpd)
;;; init-simple-httpd.el ends here
