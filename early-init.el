;;; early-init.el --- Early startup for Lantern -*- lexical-binding: t; -*-

(defconst lantern-root-dir
  (file-name-as-directory
   (file-name-directory (or load-file-name buffer-file-name user-emacs-directory)))
  "Root directory for Lantern Emacs.")

(defconst lantern-local-dir
  (expand-file-name ".local/" lantern-root-dir)
  "Local data directory for Lantern Emacs.")

(make-directory lantern-local-dir t)

(setq user-emacs-directory lantern-root-dir
      package-enable-at-startup nil
      frame-inhibit-implied-resize t
      inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      read-process-output-max (* 1024 1024)
      gc-cons-threshold most-positive-fixnum
      use-short-answers t)

(when (and (fboundp 'startup-redirect-eln-cache)
           (boundp 'native-comp-eln-load-path))
  (startup-redirect-eln-cache (expand-file-name "eln-cache/" lantern-local-dir)))

(dolist (fn '(menu-bar-mode tool-bar-mode scroll-bar-mode))
  (when (fboundp fn)
    (funcall fn -1)))
