;;; verify.el --- Lantern batch smoke test -*- lexical-binding: t; -*-

(let* ((script-dir (file-name-directory (or load-file-name buffer-file-name)))
       (root (file-name-as-directory (expand-file-name ".." script-dir))))
  (setq user-emacs-directory root)
  (load-file (expand-file-name "early-init.el" root))
  (load-file (expand-file-name "init.el" root)))

(dolist (feature '(lantern lantern-core lantern-ui lantern-completion
                           lantern-project lantern-prog lantern-onboarding lantern-keys))
  (unless (featurep feature)
    (error "Missing feature: %s" feature)))

(dolist (fn '(lantern/welcome lantern/find-file lantern/search
               lantern/doctor lantern/command-palette lantern/open-config))
  (unless (fboundp fn)
    (error "Missing function: %s" fn)))

(princ "Lantern smoke test passed.

")
(princ (lantern/doctor-report-string))
(princ "
")
