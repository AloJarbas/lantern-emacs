;;; lantern-core.el --- Core defaults for Lantern -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)

(defconst lantern-root-dir
  (file-name-as-directory
   (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name))))
  "Root directory for Lantern Emacs.")

(defconst lantern-local-dir (expand-file-name ".local/" lantern-root-dir))
(defconst lantern-cache-dir (expand-file-name "cache/" lantern-local-dir))
(defconst lantern-var-dir (expand-file-name "var/" lantern-local-dir))
(defconst lantern-backup-dir (expand-file-name "backups/" lantern-var-dir))
(defconst lantern-autosave-dir (expand-file-name "auto-save/" lantern-var-dir))

(dolist (dir (list lantern-local-dir lantern-cache-dir lantern-var-dir
                   lantern-backup-dir lantern-autosave-dir))
  (make-directory dir t))

(defconst lantern-minimum-emacs-version "29.1")

(when (version< emacs-version lantern-minimum-emacs-version)
  (error "Lantern needs Emacs %s+ (found %s)" lantern-minimum-emacs-version emacs-version))

(setq user-emacs-directory lantern-root-dir
      custom-file (expand-file-name "custom.el" lantern-var-dir)
      backup-directory-alist `(("." . ,lantern-backup-dir))
      auto-save-file-name-transforms `((".*" ,lantern-autosave-dir t))
      auto-save-list-file-prefix (expand-file-name ".saves-" lantern-autosave-dir)
      create-lockfiles nil
      make-backup-files t
      ring-bell-function #'ignore
      visible-bell nil
      sentence-end-double-space nil
      use-dialog-box nil
      history-length 200
      recentf-max-saved-items 200
      recentf-save-file (expand-file-name "recentf" lantern-var-dir)
      savehist-file (expand-file-name "history" lantern-var-dir)
      save-place-file (expand-file-name "places" lantern-var-dir)
      project-list-file (expand-file-name "projects.eld" lantern-var-dir)
      initial-scratch-message ";; Lantern scratch. Try M-SPC or C-c l w.\n\n"
      initial-major-mode 'text-mode
      tab-always-indent 'complete
      compilation-scroll-output t
      completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 88)

(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(winner-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(delete-selection-mode 1)

(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil
      savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

(require 'package)

(setq package-user-dir (expand-file-name "elpa/" lantern-local-dir)
      package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t)

(use-package gcmh
  :init
  (gcmh-mode 1))

(use-package which-key
  :init
  (which-key-mode 1)
  :custom
  (which-key-idle-delay 0.4)
  (which-key-sort-order #'which-key-prefix-then-key-order)
  (which-key-max-description-length 42))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :config
  (exec-path-from-shell-initialize))

(defun lantern/open-config ()
  "Open the Lantern config root in Dired."
  (interactive)
  (dired lantern-root-dir))

(defconst lantern-required-tools
  '(("git" . "needed for package bootstrap and project work")
    ("rg" . "used by consult-ripgrep for project search"))
  "Core external tools Lantern cares about.")

(defconst lantern-language-servers
  '(("pyright-langserver" . "Python")
    ("typescript-language-server" . "TypeScript / JavaScript")
    ("gopls" . "Go")
    ("rust-analyzer" . "Rust")
    ("yaml-language-server" . "YAML"))
  "Language servers Lantern knows how to talk to.")

(defun lantern--doctor-line (binary label)
  (format "%s %-24s %s"
          (if (executable-find binary) "✓" "·")
          binary
          label))

(defun lantern/doctor-report-lines ()
  "Return doctor output as a list of lines."
  (append
   (list (format "Lantern doctor — Emacs %s" emacs-version)
         (format "root:  %s" lantern-root-dir)
         (format "local: %s" lantern-local-dir)
         ""
         "Core tools")
   (mapcar (lambda (item) (lantern--doctor-line (car item) (cdr item)))
           lantern-required-tools)
   (list ""
         "Language servers")
   (mapcar (lambda (item) (lantern--doctor-line (car item) (cdr item)))
           lantern-language-servers)
   (list ""
         "Tip: missing language servers are fine on day one; install them when you care about that language.")))

(defun lantern/doctor-report-string ()
  "Return doctor output as a single string."
  (string-join (lantern/doctor-report-lines) "\n"))

(defun lantern/doctor ()
  "Show a Lantern environment report."
  (interactive)
  (let ((buffer (get-buffer-create "*Lantern Doctor*")))
    (with-current-buffer buffer
      (read-only-mode -1)
      (erase-buffer)
      (insert (lantern/doctor-report-string))
      (goto-char (point-min))
      (special-mode))
    (pop-to-buffer buffer)))

(provide 'lantern-core)
