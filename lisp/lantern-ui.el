;;; lantern-ui.el --- UI polish for Lantern -*- lexical-binding: t; -*-

(use-package doom-themes
  :config
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config))

(use-package doom-modeline
  :unless noninteractive
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 24)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-major-mode-icon nil))

(setq frame-title-format '("Lantern — %b")
      display-line-numbers-type 'relative
      window-divider-default-places t
      window-divider-default-right-width 1
      window-divider-default-bottom-width 1)

(global-hl-line-mode 1)
(column-number-mode 1)
(size-indication-mode 1)
(blink-cursor-mode 0)

(when (fboundp 'set-fringe-mode)
  (set-fringe-mode 10))

(when (fboundp 'window-divider-mode)
  (window-divider-mode 1))

(add-hook 'text-mode-hook #'visual-line-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)

(dolist (hook '(term-mode-hook shell-mode-hook eshell-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode 0))))

(provide 'lantern-ui)
