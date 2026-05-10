;;; init.el --- Entry point for Lantern -*- lexical-binding: t; -*-

(let* ((root (file-name-as-directory
              (file-name-directory (or load-file-name buffer-file-name user-emacs-directory))))
       (lisp-dir (expand-file-name "lisp/" root)))
  (setq user-emacs-directory root)
  (add-to-list 'load-path lisp-dir)
  (require 'lantern))
