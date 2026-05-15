;;; lantern-ui.el --- UI polish for Lantern -*- lexical-binding: t; -*-

(defgroup lantern-ui nil
  "UI polish for Lantern."
  :group 'convenience)

(defcustom lantern-dark-theme 'doom-one
  "Default dark theme for Lantern."
  :type 'symbol)

(defcustom lantern-light-theme 'doom-one-light
  "Default light theme for Lantern."
  :type 'symbol)

(defcustom lantern-default-font-height 140
  "Default font height for Lantern buffers."
  :type 'integer)

(defcustom lantern-font-height-step 10
  "Step size used by Lantern font size commands."
  :type 'integer)

(defvar lantern-current-theme-variant 'dark
  "Current Lantern theme variant.")

(defvar lantern-current-font-height lantern-default-font-height
  "Current Lantern font height.")

(defface lantern-ui-title-face
  '((t (:height 1.5 :weight bold)))
  "Face for large Lantern titles.")

(defface lantern-ui-subtitle-face
  '((t (:inherit shadow :height 1.02)))
  "Face for Lantern subtitles.")

(defface lantern-ui-section-face
  '((t (:weight bold :height 1.12)))
  "Face for section headings in Lantern UI screens.")

(defface lantern-ui-button-face
  '((t (:inherit link :weight semi-bold
        :box (:line-width (1 . -1) :style released-button))))
  "Face for interactive Lantern buttons.")

(defface lantern-ui-keycap-face
  '((t (:inherit font-lock-keyword-face :weight semi-bold
        :box (:line-width (1 . -1) :style released-button))))
  "Face for keycap-style hints in Lantern screens.")

(defface lantern-ui-note-face
  '((t (:inherit shadow)))
  "Face for small explanatory notes in Lantern screens.")

(defface lantern-ui-metric-face
  '((t (:inherit font-lock-keyword-face :weight semi-bold)))
  "Face for short UI metrics and state readouts.")

(defun lantern/current-theme-name ()
  "Return the active Lantern theme name as a string."
  (symbol-name
   (if (eq lantern-current-theme-variant 'dark)
       lantern-dark-theme
     lantern-light-theme)))

(defun lantern/apply-font-height (height)
  "Apply Lantern font HEIGHT, clamped to a sane range."
  (setq lantern-current-font-height (max 90 (min 220 height)))
  (set-face-attribute 'default nil :height lantern-current-font-height))

(defun lantern/increase-font-size ()
  "Increase the default font size for the current session."
  (interactive)
  (lantern/apply-font-height (+ lantern-current-font-height lantern-font-height-step))
  (message "Lantern font height: %d" lantern-current-font-height))

(defun lantern/decrease-font-size ()
  "Decrease the default font size for the current session."
  (interactive)
  (lantern/apply-font-height (- lantern-current-font-height lantern-font-height-step))
  (message "Lantern font height: %d" lantern-current-font-height))

(defun lantern/reset-font-size ()
  "Reset the Lantern font size to its default."
  (interactive)
  (lantern/apply-font-height lantern-default-font-height)
  (message "Lantern font height: %d" lantern-current-font-height))

(defun lantern/new-tab ()
  "Open a new tab when tab-bar support is available."
  (interactive)
  (if (fboundp 'tab-bar-new-tab)
      (call-interactively #'tab-bar-new-tab)
    (user-error "Tab bar support is not available")))

(defun lantern/close-tab ()
  "Close the current tab when tab-bar support is available."
  (interactive)
  (if (fboundp 'tab-bar-close-tab)
      (call-interactively #'tab-bar-close-tab)
    (user-error "Tab bar support is not available")))

(defun lantern/rename-tab ()
  "Rename the current tab when tab-bar support is available."
  (interactive)
  (if (fboundp 'tab-bar-rename-tab)
      (call-interactively #'tab-bar-rename-tab)
    (user-error "Tab bar support is not available")))

(defun lantern/next-tab ()
  "Move to the next tab when tab-bar support is available."
  (interactive)
  (if (fboundp 'tab-next)
      (call-interactively #'tab-next)
    (user-error "Tab bar support is not available")))

(defun lantern/previous-tab ()
  "Move to the previous tab when tab-bar support is available."
  (interactive)
  (if (fboundp 'tab-previous)
      (call-interactively #'tab-previous)
    (user-error "Tab bar support is not available")))

(defun lantern/refresh-ui-faces ()
  "Tighten a few stock faces so Lantern's chrome stays calmer."
  (when (facep 'mode-line)
    (set-face-attribute 'mode-line nil :box nil))
  (when (facep 'mode-line-inactive)
    (set-face-attribute 'mode-line-inactive nil :box nil))
  (when (facep 'tab-bar)
    (set-face-attribute 'tab-bar nil :box nil :height 0.95))
  (when (facep 'tab-bar-tab)
    (set-face-attribute 'tab-bar-tab nil :box nil :weight 'semi-bold))
  (when (facep 'tab-bar-tab-inactive)
    (set-face-attribute 'tab-bar-tab-inactive nil :box nil)))

(defun lantern/apply-theme (theme variant)
  "Load THEME and mark Lantern as using VARIANT."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t)
  (setq lantern-current-theme-variant variant)
  (lantern/refresh-ui-faces))

(defun lantern/toggle-theme ()
  "Toggle between Lantern's dark and light themes."
  (interactive)
  (if (eq lantern-current-theme-variant 'dark)
      (lantern/apply-theme lantern-light-theme 'light)
    (lantern/apply-theme lantern-dark-theme 'dark))
  (message "Lantern theme: %s"
           (symbol-name
            (if (eq lantern-current-theme-variant 'dark)
                lantern-dark-theme
              lantern-light-theme))))

(defun lantern/ui-prepare-special-buffer ()
  "Apply a calmer layout for Lantern's guided UI buffers."
  (setq-local cursor-type nil
              mode-line-format nil
              line-spacing 0.22
              truncate-lines nil)
  (visual-line-mode 1))

(defun lantern/ui-display-buffer (buffer)
  "Show BUFFER with relaxed margins."
  (pop-to-buffer buffer)
  (when-let ((window (get-buffer-window buffer t)))
    (set-window-margins window 4 2)))

(use-package doom-themes
  :config
  (lantern/apply-theme lantern-dark-theme 'dark)
  (doom-themes-visual-bell-config))

(use-package doom-modeline
  :unless noninteractive
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-modal-icon nil)
  (doom-modeline-minor-modes nil))

(setq frame-title-format '("Lantern — %b")
      display-line-numbers-type 'relative
      window-resize-pixelwise t
      window-divider-default-places t
      window-divider-default-right-width 1
      window-divider-default-bottom-width 1)

(menu-bar-mode -1)

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(when (fboundp 'tooltip-mode)
  (tooltip-mode -1))

(global-hl-line-mode 1)
(column-number-mode 1)
(size-indication-mode 1)
(blink-cursor-mode 0)

(lantern/apply-font-height lantern-default-font-height)

(when (fboundp 'set-fringe-mode)
  (set-fringe-mode 10))

(when (fboundp 'window-divider-mode)
  (window-divider-mode 1))

(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

(when (fboundp 'tab-bar-mode)
  (setq tab-bar-show 1
        tab-bar-close-button-show nil
        tab-bar-new-button-show nil
        tab-bar-separator "  ")
  (tab-bar-mode 1))

(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

(dolist (hook '(term-mode-hook shell-mode-hook eshell-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode 0))))

(provide 'lantern-ui)
