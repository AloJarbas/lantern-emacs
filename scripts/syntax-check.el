;;; syntax-check.el --- Parse Lantern Lisp files without loading packages -*- lexical-binding: t; -*-

(let* ((script-dir (file-name-directory (or load-file-name buffer-file-name)))
       (root (file-name-as-directory (expand-file-name ".." script-dir)))
       (files (directory-files-recursively root "\\.el\\'"))
       errors
       (checked 0))
  (dolist (file files)
    (unless (string-match-p "/\\.local/" file)
      (setq checked (1+ checked))
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (condition-case err
            (while t
              (read (current-buffer)))
          (end-of-file nil)
          (error (push (format "%s: %s" file (error-message-string err)) errors))))))
  (if errors
      (progn
        (princ "Lantern syntax check failed.\n\n")
        (dolist (entry (nreverse errors))
          (princ entry)
          (princ "\n"))
        (kill-emacs 1))
    (princ (format "Lantern syntax check passed for %d files.\n" checked))))
