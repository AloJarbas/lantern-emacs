;;; lantern.el --- Main Lantern loader -*- lexical-binding: t; -*-

(require 'lantern-core)
(require 'lantern-ui)
(require 'lantern-completion)
(require 'lantern-project)
(require 'lantern-prog)
(require 'lantern-onboarding)
(require 'lantern-keys)

(load custom-file t)
(add-hook 'emacs-startup-hook #'lantern/show-startup-experience)

(provide 'lantern)
