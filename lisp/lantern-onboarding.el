;;; lantern-onboarding.el --- First-run experience for Lantern -*- lexical-binding: t; -*-

(require 'button)
(require 'cl-lib)
(require 'seq)

(defconst lantern-first-run-file
  (expand-file-name "first-run-seen" lantern-var-dir)
  "Marker file written after Lantern shows the welcome screen.")

(defconst lantern-welcome-buffer-name "*Lantern Welcome*")

(defun lantern--welcome-button (label action help)
  (insert-text-button (format " %s " label)
                      'face 'lantern-ui-button-face
                      'follow-link t
                      'help-echo help
                      'action (lambda (_button) (call-interactively action))))

(defun lantern--welcome-keycap (text)
  (propertize (format " %s " text) 'face 'lantern-ui-keycap-face))

(defun lantern--welcome-open-project (root)
  "Open project ROOT from the welcome screen." 
  (interactive)
  (let ((default-directory root))
    (call-interactively #'project-find-file)))

(defun lantern--welcome-recent-projects ()
  "Insert a short recent-project list into the welcome screen."
  (let ((projects (seq-take (lantern--known-project-roots) 3)))
    (if projects
        (dolist (root projects)
          (insert "  ")
          (insert-text-button (file-name-nondirectory (directory-file-name root))
                              'follow-link t
                              'face 'link
                              'help-echo root
                              'action (lambda (_button)
                                        (lantern--welcome-open-project root)))
          (insert (format "  —  %s\n" root)))
      (insert (propertize "  No project history yet. Open a repo and Lantern will start remembering it.\n"
                          'face 'lantern-ui-note-face)))))

(defun lantern--welcome-recent-files ()
  "Insert a short recent-file list into the welcome screen."
  (let ((files (seq-take (lantern--recent-existing-files) 3)))
    (if files
        (dolist (file files)
          (insert "  ")
          (insert-text-button (file-name-nondirectory file)
                              'follow-link t
                              'face 'link
                              'help-echo file
                              'action (lambda (_button) (find-file file)))
          (insert (format "  —  %s\n" (abbreviate-file-name file))))
      (insert (propertize "  No recent files yet.\n" 'face 'lantern-ui-note-face)))))

(defun lantern/open-readme ()
  "Open the Lantern README."
  (interactive)
  (find-file (expand-file-name "README.md" lantern-root-dir)))

(defun lantern/open-language-guide ()
  "Open Lantern's language-server guide."
  (interactive)
  (find-file (expand-file-name "docs/languages.md" lantern-root-dir)))

(defun lantern/welcome ()
  "Show the Lantern welcome buffer."
  (interactive)
  (let ((buffer (get-buffer-create lantern-welcome-buffer-name)))
    (with-current-buffer buffer
      (read-only-mode -1)
      (erase-buffer)
      (lantern/ui-prepare-special-buffer)
      (insert (propertize "lantern-emacs\n" 'face 'lantern-ui-title-face))
      (insert (propertize "Emacs that tries to help before it lectures.\n\n"
                          'face 'lantern-ui-subtitle-face))
      (insert (propertize "Session snapshot\n" 'face 'lantern-ui-section-face))
      (insert (format "  Theme: %s   Font: %s   Tabs: %s\n\n"
                      (propertize (lantern/current-theme-name) 'face 'lantern-ui-metric-face)
                      (propertize (format "%d" lantern-current-font-height) 'face 'lantern-ui-metric-face)
                      (propertize (if (bound-and-true-p tab-bar-mode) "on" "off") 'face 'lantern-ui-metric-face)))
      (insert (propertize "Start here\n" 'face 'lantern-ui-section-face))
      (insert "  ")
      (lantern--welcome-button "Find a file" #'lantern/find-file "Open a file or project file")
      (insert "\n  ")
      (lantern--welcome-button "Switch project" #'lantern/switch-project "Jump into another project")
      (insert "\n  ")
      (lantern--welcome-button "Command center" #'lantern/command-center "Open the all-in-one command hub")
      (insert "\n  ")
      (lantern--welcome-button "Toggle theme" #'lantern/toggle-theme "Switch between Lantern's dark and light themes")
      (insert "\n  ")
      (lantern--welcome-button "Bigger text" #'lantern/increase-font-size "Increase the editor font size")
      (insert "\n  ")
      (lantern--welcome-button "Smaller text" #'lantern/decrease-font-size "Decrease the editor font size")
      (insert "\n  ")
      (lantern--welcome-button "New tab" #'lantern/new-tab "Open a fresh tab for another task")
      (insert "\n  ")
      (lantern--welcome-button "Search code" #'lantern/search "Search with ripgrep")
      (insert "\n  ")
      (lantern--welcome-button "Open Magit" #'magit-status "Open Git status")
      (insert "\n  ")
      (lantern--welcome-button "Check environment" #'lantern/doctor "Show tools and language servers")
      (insert "\n  ")
      (lantern--welcome-button "Read quick start" #'lantern/open-readme "Open the README inside Lantern")
      (insert "\n  ")
      (lantern--welcome-button "Language guide" #'lantern/open-language-guide "Open language-server notes and setup hints")
      (insert "\n  ")
      (lantern--welcome-button "Open config" #'lantern/open-config "Browse Lantern itself")
      (insert "\n\n")
      (insert (propertize "Jump back in\n" 'face 'lantern-ui-section-face))
      (insert (propertize "Recent projects\n" 'face 'lantern-ui-note-face))
      (lantern--welcome-recent-projects)
      (insert "\n")
      (insert (propertize "Recent files\n" 'face 'lantern-ui-note-face))
      (lantern--welcome-recent-files)
      (insert "\n")
      (insert (propertize "Look and feel\n" 'face 'lantern-ui-section-face))
      (insert "  ")
      (lantern--welcome-button "Reset text" #'lantern/reset-font-size "Reset the default font size")
      (insert "\n  ")
      (lantern--welcome-button "Rename tab" #'lantern/rename-tab "Give the current tab a clearer name")
      (insert "\n  ")
      (lantern--welcome-button "Next tab" #'lantern/next-tab "Move to the next tab")
      (insert "\n\n")
      (insert (propertize "Fast keys\n" 'face 'lantern-ui-section-face))
      (insert (format "  %s  command palette\n" (lantern--welcome-keycap "M-SPC")))
      (insert (format "  %s  Lantern menu\n" (lantern--welcome-keycap "C-c l")))
      (insert (format "  %s  command center\n" (lantern--welcome-keycap "C-c l c")))
      (insert (format "  %s  toggle theme\n" (lantern--welcome-keycap "C-c l t")))
      (insert (format "  %s  bigger text\n" (lantern--welcome-keycap "C-c l =")))
      (insert (format "  %s  smaller text\n" (lantern--welcome-keycap "C-c l -")))
      (insert (format "  %s  reset text\n" (lantern--welcome-keycap "C-c l 0")))
      (insert (format "  %s  new tab\n" (lantern--welcome-keycap "C-c l T")))
      (insert (format "  %s  find file\n" (lantern--welcome-keycap "C-c l f")))
      (insert (format "  %s  search project\n" (lantern--welcome-keycap "C-c l s")))
      (insert (format "  %s  switch buffer\n" (lantern--welcome-keycap "C-c l b")))
      (insert (format "  %s  switch project\n" (lantern--welcome-keycap "C-c l p")))
      (insert (format "  %s  Magit\n" (lantern--welcome-keycap "C-c l g")))
      (insert (format "  %s  candidate actions\n" (lantern--welcome-keycap "C-.")))
      (insert (format "  %s  close this screen\n\n" (lantern--welcome-keycap "q")))
      (insert (propertize "Why this feels lighter\n" 'face 'lantern-ui-section-face))
      (insert (propertize "  Lantern keeps state inside .local/, uses stock Emacs concepts where possible, and gives you a map on first run instead of assuming you already know the terrain.\n\n"
                          'face 'lantern-ui-note-face))
      (insert (propertize "Next practical step\n" 'face 'lantern-ui-section-face))
      (insert (propertize "  Open a repo, hit C-c l s, and see whether project search feels obvious enough. If it does, the MVP is doing its job.\n"
                          'face 'lantern-ui-note-face))
      (goto-char (point-min))
      (special-mode))
    (unless (file-exists-p lantern-first-run-file)
      (write-region "seen\n" nil lantern-first-run-file nil 'silent))
    (lantern/ui-display-buffer buffer)))

(defun lantern/show-startup-experience ()
  "Open the welcome buffer on first run or when no file was requested."
  (when (and (not noninteractive)
             (or (not (file-exists-p lantern-first-run-file))
                 (null command-line-args-left))
             (not (cl-some #'buffer-file-name (buffer-list))))
    (lantern/welcome)))

(provide 'lantern-onboarding)
