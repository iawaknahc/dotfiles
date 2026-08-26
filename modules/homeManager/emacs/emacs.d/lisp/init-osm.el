;;; init-osm.el --- init-osm.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq
 ;; Roughly the center of Hong Kong at zoom level 11.
 calendar-latitude 22.34
 calendar-longitude 114.17
 ;; The zoom level the whole Hong Kong can be displayed on my MacBook.
 osm-default-zoom 11
 ;; Use the MapTiler tile server defined below.
 osm-default-server 'maptiler-streets)

(with-eval-after-load 'osm
  (osm-add-server 'maptiler-streets
    :name "MapTiler Streets"
    :description "This style includes landmarks and road names, displayed in both Chinese and English."
    :group "MapTiler"
    :url "https://api.maptiler.com/maps/streets/256/%z/%x/%y@2x.png?key=%k"))

(defun my/osm-vulpea (tag)
  "Open a osm buffer with waypoints populated by TAG.

When called interactively, prompt for TAG.
Use `vulpea-db-query-by-tags-some' to fetch all vulpea notes with TAG.
For each note with `latitude' and `longitude' metadata,
convert it to a waypoint.

Finally use the private function `osm--add-dataset' to show the buffer."
  (interactive
   (list (completing-read "Pick a tag to select notes: " (vulpea-db-query-tags) nil t)))
  (let* (waypoints)
    (dolist (note (vulpea-db-query-by-tags-some (list tag)))
      (let ((lat (vulpea-note-meta-get note "latitude" 'number))
            (lon (vulpea-note-meta-get note "longitude" 'number)))
        (when (and lat lon)
          (push (list lat lon (vulpea-note-title note)) waypoints))))
    (unless waypoints
      (user-error "No notes tagged %S have latitude/longitude metadata" tag))
    (osm--add-dataset (format "vulpea notes with tag :%s:" tag) 'osm-file nil (nreverse waypoints))))

(provide 'init-osm)
;;; init-osm.el ends here
