;;; doctor.el --- Lantern doctor batch entrypoint -*- lexical-binding: t; -*-

(let* ((script-dir (file-name-directory (or load-file-name buffer-file-name)))
       (root (file-name-as-directory (expand-file-name ".." script-dir))))
  (setq user-emacs-directory root)
  (load-file (expand-file-name "early-init.el" root))
  (load-file (expand-file-name "init.el" root)))

(princ (lantern/doctor-report-string))
(princ "
")
