;;; lantern-keys.el --- Keybindings for Lantern -*- lexical-binding: t; -*-

(defvar lantern-leader-map (make-sparse-keymap)
  "Keymap for Lantern commands.")

(define-key global-map (kbd "C-c l") lantern-leader-map)
(global-set-key (kbd "M-SPC") #'lantern/command-palette)
(global-set-key (kbd "C-x g") #'magit-status)

(define-key lantern-leader-map (kbd "SPC") #'lantern/command-palette)
(define-key lantern-leader-map (kbd "w") #'lantern/welcome)
(define-key lantern-leader-map (kbd "c") #'lantern/command-center)
(define-key lantern-leader-map (kbd "f") #'lantern/find-file)
(define-key lantern-leader-map (kbd "s") #'lantern/search)
(define-key lantern-leader-map (kbd "b") #'consult-buffer)
(define-key lantern-leader-map (kbd "r") #'lantern/recent-file)
(define-key lantern-leader-map (kbd "p") #'lantern/switch-project)
(define-key lantern-leader-map (kbd "P") #'lantern/project-buffer)
(define-key lantern-leader-map (kbd "g") #'magit-status)
(define-key lantern-leader-map (kbd "d") #'lantern/doctor)
(define-key lantern-leader-map (kbd "e") #'lantern/open-config)
(define-key lantern-leader-map (kbd "t") #'lantern/toggle-theme)
(define-key lantern-leader-map (kbd "=") #'lantern/increase-font-size)
(define-key lantern-leader-map (kbd "-") #'lantern/decrease-font-size)
(define-key lantern-leader-map (kbd "0") #'lantern/reset-font-size)
(define-key lantern-leader-map (kbd "T") #'lantern/new-tab)
(define-key lantern-leader-map (kbd "R") #'lantern/rename-tab)
(define-key lantern-leader-map (kbd "W") #'lantern/close-tab)
(define-key lantern-leader-map (kbd "]") #'lantern/next-tab)
(define-key lantern-leader-map (kbd "[") #'lantern/previous-tab)
(define-key lantern-leader-map (kbd "l") #'eglot)

(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c l" "Lantern"
    "C-c l SPC" "command palette"
    "C-c l w" "welcome"
    "C-c l c" "command center"
    "C-c l f" "find file"
    "C-c l s" "search"
    "C-c l b" "buffers"
    "C-c l r" "recent files"
    "C-c l p" "projects"
    "C-c l P" "project buffers"
    "C-c l g" "git"
    "C-c l d" "doctor"
    "C-c l e" "edit config"
    "C-c l t" "toggle theme"
    "C-c l =" "bigger text"
    "C-c l -" "smaller text"
    "C-c l 0" "reset text"
    "C-c l T" "new tab"
    "C-c l R" "rename tab"
    "C-c l W" "close tab"
    "C-c l [" "previous tab"
    "C-c l ]" "next tab"
    "C-c l l" "start LSP"))

(provide 'lantern-keys)
