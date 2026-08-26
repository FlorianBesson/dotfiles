;;; init.el -*- lexical-binding: t; -*-

;; avoid gauth prompt https://github.com/emacsmirror/org-gcal?tab=readme-ov-file#Installation
(setq plstore-cache-passphrase-for-symmetric-encryption t)
(doom! :input

       :completion
       company
       vertico


       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       (popup +defaults)
       vi-tilde-fringe
       ;;workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets

       :emacs
       dired
       electric
       undo
       vc

       :term
       vterm

       :checkers
       syntax
       ;; (spell +flyspell)

       :tools
       (eval +overlay)
       lookup
       magit

       :os
       (:if IS-MAC macos)

       :lang
       emacs-lisp
       markdown
       (org +roam2)
       sh

       :config
       (default +bindings +smartparens))

