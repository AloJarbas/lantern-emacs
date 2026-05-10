;;; lantern-project.el --- Project and Git ergonomics -*- lexical-binding: t; -*-

(require 'project)
(require 'consult)

(use-package magit
  :commands (magit-status))

(defun lantern/project-root ()
  "Return the current project root, or nil."
  (when-let ((project (project-current nil)))
    (project-root project)))

(defun lantern/find-file ()
  "Find a file, preferring the current project when possible."
  (interactive)
  (if (project-current nil)
      (call-interactively #'project-find-file)
    (call-interactively #'find-file)))

(defun lantern/search ()
  "Search the current project with ripgrep, or search from `default-directory'."
  (interactive)
  (consult-ripgrep (or (lantern/project-root) default-directory)))

(defun lantern/switch-project ()
  "Jump to another project."
  (interactive)
  (call-interactively #'project-switch-project))

(defun lantern/recent-file ()
  "Open a recent file with preview."
  (interactive)
  (call-interactively #'consult-recent-file))

(defun lantern/project-buffer ()
  "Switch to a project buffer."
  (interactive)
  (call-interactively #'consult-project-buffer))

(when (boundp 'project-switch-commands)
  (setq project-switch-commands
        '((lantern/find-file "Find file" ?f)
          (lantern/project-buffer "Project buffer" ?b)
          (lantern/search "Search" ?s)
          (magit-project-status "Magit" ?g)
          (project-dired "Dired" ?d))))

(setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)

(provide 'lantern-project)
