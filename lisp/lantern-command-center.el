;;; lantern-command-center.el --- Discoverable command hub for Lantern -*- lexical-binding: t; -*-

(require 'button)
(require 'cl-lib)
(require 'project)
(require 'recentf)
(require 'seq)
(require 'subr-x)

(defconst lantern-command-center-buffer-name "*Lantern Command Center*")

(defun lantern--command-center-button (label action help)
  (insert "  ")
  (insert-text-button label
                      'follow-link t
                      'help-echo help
                      'action (lambda (_button) (call-interactively action)))
  (insert "\n"))

(defun lantern--command-center-heading (title)
  (insert (propertize title 'face '(:weight bold :height 1.15)))
  (insert "\n"))

(defun lantern--known-project-roots ()
  "Return known project roots, newest first when available."
  (cl-remove-if-not
   #'file-directory-p
   (delete-dups
    (or (when (fboundp 'project-known-project-roots)
          (project-known-project-roots))
        '()))))

(defun lantern--recent-existing-files ()
  "Return recent files that still exist on disk."
  (cl-remove-if-not #'file-exists-p recentf-list))

(defun lantern/find-file-in-known-project (root)
  "Find a file inside the known project ROOT."
  (interactive
   (list (completing-read "Project: " (lantern--known-project-roots) nil t)))
  (let ((default-directory (file-name-as-directory root)))
    (call-interactively #'project-find-file)))

(defun lantern/open-known-project (root)
  "Open project ROOT in Dired."
  (interactive
   (list (completing-read "Project: " (lantern--known-project-roots) nil t)))
  (dired root))

(defun lantern/show-buffer-diagnostics ()
  "Show diagnostics for the current buffer when available."
  (interactive)
  (if (fboundp 'flymake-show-buffer-diagnostics)
      (call-interactively #'flymake-show-buffer-diagnostics)
    (user-error "Flymake diagnostics are not available in this buffer")))

(defun lantern/show-project-diagnostics ()
  "Show project diagnostics when available."
  (interactive)
  (if (fboundp 'flymake-show-project-diagnostics)
      (call-interactively #'flymake-show-project-diagnostics)
    (user-error "Project diagnostics are not available here")))

(defun lantern/magit-project-status ()
  "Open Magit for the current project when possible."
  (interactive)
  (if (project-current nil)
      (call-interactively #'magit-project-status)
    (call-interactively #'magit-status)))

(defun lantern/eglot-code-actions ()
  "Run Eglot code actions when Eglot is available."
  (interactive)
  (require 'eglot nil t)
  (if (fboundp 'eglot-code-actions)
      (call-interactively #'eglot-code-actions)
    (user-error "Eglot code actions are not available")))

(defun lantern/eglot-rename ()
  "Rename the symbol at point through Eglot when available."
  (interactive)
  (require 'eglot nil t)
  (if (fboundp 'eglot-rename)
      (call-interactively #'eglot-rename)
    (user-error "Eglot rename is not available")))

(defun lantern/eglot-format-buffer ()
  "Format the current buffer through Eglot when available."
  (interactive)
  (require 'eglot nil t)
  (if (fboundp 'eglot-format-buffer)
      (call-interactively #'eglot-format-buffer)
    (user-error "Eglot formatting is not available")))

(defun lantern/helpful-at-point-or-symbol ()
  "Show help at point, falling back to symbol help."
  (interactive)
  (cond
   ((fboundp 'helpful-at-point)
    (call-interactively #'helpful-at-point))
   ((fboundp 'describe-symbol)
    (call-interactively #'describe-symbol))
   (t
    (user-error "Symbol help is not available"))))

(defun lantern--insert-known-project-shortcuts ()
  (let ((projects (seq-take (lantern--known-project-roots) 4)))
    (if projects
        (progn
          (insert "  Known projects\n")
          (dolist (root projects)
            (let ((name (file-name-nondirectory (directory-file-name root))))
              (insert "    ")
              (insert-text-button (format "%s" name)
                                  'follow-link t
                                  'help-echo root
                                  'action (lambda (_button)
                                            (lantern/find-file-in-known-project root)))
              (insert (format "  —  %s\n" root)))))
      (insert "  No project history yet. Open a few repos and this section fills itself in.\n")))
  (insert "\n"))

(defun lantern--insert-recent-file-shortcuts ()
  (let ((files (seq-take (lantern--recent-existing-files) 4)))
    (if files
        (progn
          (insert "  Recent files\n")
          (dolist (file files)
            (insert "    ")
            (insert-text-button (file-name-nondirectory file)
                                'follow-link t
                                'help-echo file
                                'action (lambda (_button) (find-file file)))
            (insert (format "  —  %s\n" (abbreviate-file-name file)))))
      (insert "  No recent files yet.\n")))
  (insert "\n"))

(defun lantern/command-center ()
  "Open Lantern's command center."
  (interactive)
  (let ((buffer (get-buffer-create lantern-command-center-buffer-name)))
    (with-current-buffer buffer
      (read-only-mode -1)
      (erase-buffer)
      (setq-local line-spacing 0.15)
      (insert (propertize "Lantern command center\n" 'face '(:height 1.45 :weight bold)))
      (insert "One place for the commands you need before muscle memory exists.\n\n")

      (lantern--command-center-heading "Projects")
      (lantern--command-center-button "Switch project" #'lantern/switch-project "Jump to another known project")
      (lantern--command-center-button "Project buffer" #'lantern/project-buffer "Switch to a buffer in the current project")
      (lantern--insert-known-project-shortcuts)

      (lantern--command-center-heading "Files and search")
      (lantern--command-center-button "Find file" #'lantern/find-file "Open a file, project-aware when possible")
      (lantern--command-center-button "Search project" #'lantern/search "Search with ripgrep from the current project")
      (lantern--command-center-button "Recent files" #'lantern/recent-file "Browse recent files with preview")
      (lantern--insert-recent-file-shortcuts)

      (lantern--command-center-heading "Docs and help")
      (lantern--command-center-button "Open README" #'lantern/open-readme "Read Lantern's quick start and layout")
      (lantern--command-center-button "Language guide" #'lantern/open-language-guide "See language-server setup notes")
      (lantern--command-center-button "Help at point" #'lantern/helpful-at-point-or-symbol "Explain the symbol at point")
      (lantern--command-center-button "Edit Lantern config" #'lantern/open-config "Browse the config root in Dired")
      (insert "\n")

      (lantern--command-center-heading "Git and diagnostics")
      (lantern--command-center-button "Magit status" #'magit-status "Open Git status")
      (lantern--command-center-button "Project Magit" #'lantern/magit-project-status "Open Magit for the current project")
      (lantern--command-center-button "Lantern doctor" #'lantern/doctor "Check tools and language servers")
      (lantern--command-center-button "Buffer diagnostics" #'lantern/show-buffer-diagnostics "Show Flymake diagnostics for this buffer")
      (lantern--command-center-button "Project diagnostics" #'lantern/show-project-diagnostics "Show project diagnostics when supported")
      (insert "\n")

      (lantern--command-center-heading "Language actions")
      (lantern--command-center-button "Start or reconnect LSP" #'eglot "Start Eglot in the current buffer")
      (lantern--command-center-button "Code actions" #'lantern/eglot-code-actions "Ask the language server for code actions")
      (lantern--command-center-button "Rename symbol" #'lantern/eglot-rename "Rename the symbol at point through the language server")
      (lantern--command-center-button "Format buffer" #'lantern/eglot-format-buffer "Format the current buffer through the language server")
      (insert "\n")

      (insert (propertize "Fast keys\n" 'face '(:weight bold)))
      (insert "  C-c l c  reopen this command center\n")
      (insert "  M-SPC    raw command palette\n")
      (insert "  g        refresh this screen\n")
      (insert "  q        close this screen\n")
      (goto-char (point-min))
      (special-mode)
      (use-local-map (copy-keymap special-mode-map))
      (local-set-key (kbd "g") #'lantern/command-center))
    (pop-to-buffer buffer)))

(provide 'lantern-command-center)
