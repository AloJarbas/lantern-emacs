;;; lantern-onboarding.el --- First-run experience for Lantern -*- lexical-binding: t; -*-

(require 'button)
(require 'cl-lib)

(defconst lantern-first-run-file
  (expand-file-name "first-run-seen" lantern-var-dir)
  "Marker file written after Lantern shows the welcome screen.")

(defconst lantern-welcome-buffer-name "*Lantern Welcome*")

(defun lantern--welcome-button (label action help)
  (insert-text-button label
                      'follow-link t
                      'help-echo help
                      'action (lambda (_button) (call-interactively action))))

(defun lantern/welcome ()
  "Show the Lantern welcome buffer."
  (interactive)
  (let ((buffer (get-buffer-create lantern-welcome-buffer-name)))
    (with-current-buffer buffer
      (read-only-mode -1)
      (erase-buffer)
      (setq-local line-spacing 0.15)
      (insert (propertize "lantern-emacs\n" 'face '(:height 1.5 :weight bold)))
      (insert "Emacs that tries to help before it lectures.\n\n")
      (insert (propertize "Start here\n" 'face '(:weight bold)))
      (insert "  ")
      (lantern--welcome-button "Find a file" #'lantern/find-file "Open a file or project file")
      (insert "\n  ")
      (lantern--welcome-button "Switch project" #'lantern/switch-project "Jump into another project")
      (insert "\n  ")
      (lantern--welcome-button "Search code" #'lantern/search "Search with ripgrep")
      (insert "\n  ")
      (lantern--welcome-button "Open Magit" #'magit-status "Open Git status")
      (insert "\n  ")
      (lantern--welcome-button "Check environment" #'lantern/doctor "Show tools and language servers")
      (insert "\n  ")
      (lantern--welcome-button "Open config" #'lantern/open-config "Browse Lantern itself")
      (insert "\n\n")
      (insert (propertize "Fast keys\n" 'face '(:weight bold)))
      (insert "  M-SPC   command palette\n")
      (insert "  C-c l   Lantern menu (which-key expands it)\n")
      (insert "  C-c l f find file\n")
      (insert "  C-c l s search project\n")
      (insert "  C-c l b switch buffer\n")
      (insert "  C-c l p switch project\n")
      (insert "  C-c l g Magit\n")
      (insert "  C-.     action menu on the current candidate\n\n")
      (insert (propertize "Why this feels lighter\n" 'face '(:weight bold)))
      (insert "  Lantern keeps state inside .local/, uses stock Emacs concepts where possible, and gives you a map on first run instead of assuming you already know the terrain.\n\n")
      (insert (propertize "Next practical step\n" 'face '(:weight bold)))
      (insert "  Open a repo, hit C-c l s, and see whether project search feels obvious enough. If it does, the MVP is doing its job.\n")
      (goto-char (point-min))
      (special-mode))
    (unless (file-exists-p lantern-first-run-file)
      (write-region "seen\n" nil lantern-first-run-file nil 'silent))
    (pop-to-buffer buffer)))

(defun lantern/show-startup-experience ()
  "Open the welcome buffer on first run or when no file was requested."
  (when (and (not noninteractive)
             (or (not (file-exists-p lantern-first-run-file))
                 (null command-line-args-left))
             (not (cl-some #'buffer-file-name (buffer-list))))
    (lantern/welcome)))

(provide 'lantern-onboarding)
