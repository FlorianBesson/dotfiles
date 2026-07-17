;; packages.el -*- no-byte-compile: t; -*-

;; orgroam
(package! pangu-spacing)
(package! org-roam-ui
  :recipe (:host github :repo "org-roam/org-roam-ui"))

;; term
(package! vterm)

;; advanced agenda + query
(package! org-super-agenda)
(package! org-ql)

;; calendar google
(package! calfw)
(package! calfw-org)
(package! calfw-ical)

;; better calfw view
(package! calfw-blocks
  :recipe (:host github :repo "ml729/calfw-blocks"))
