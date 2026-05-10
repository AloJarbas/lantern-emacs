;;; lantern-keys.el --- Keybindings for Lantern -*- lexical-binding: t; -*-

(defvar lantern-leader-map (make-sparse-keymap)
  "Keymap for Lantern commands.")

(define-key global-map (kbd "C-c l") lantern-leader-map)
(global-set-key (kbd "M-SPC") #'lantern/command-palette)
(global-set-key (kbd "C-x g") #'magit-status)

(define-key lantern-leader-map (kbd "SPC") #'lantern/command-palette)
(define-key lantern-leader-map (kbd "w") #'lantern/welcome)
(define-key lantern-leader-map (kbd "f") #'lantern/find-file)
(define-key lantern-leader-map (kbd "s") #'lantern/search)
(define-key lantern-leader-map (kbd "b") #'consult-buffer)
(define-key lantern-leader-map (kbd "r") #'lantern/recent-file)
(define-key lantern-leader-map (kbd "p") #'lantern/switch-project)
(define-key lantern-leader-map (kbd "P") #'lantern/project-buffer)
(define-key lantern-leader-map (kbd "g") #'magit-status)
(define-key lantern-leader-map (kbd "d") #'lantern/doctor)
(define-key lantern-leader-map (kbd "e") #'lantern/open-config)
(define-key lantern-leader-map (kbd "l") #'eglot)

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c l" "Lantern"
    "C-c l SPC" "command palette"
    "C-c l w" "welcome"
    "C-c l f" "find file"
    "C-c l s" "search"
    "C-c l b" "buffers"
    "C-c l r" "recent files"
    "C-c l p" "projects"
    "C-c l P" "project buffers"
    "C-c l g" "git"
    "C-c l d" "doctor"
    "C-c l e" "edit config"
    "C-c l l" "start LSP"))

(provide 'lantern-keys)
