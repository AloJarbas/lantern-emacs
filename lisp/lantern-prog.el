;;; lantern-prog.el --- Programming support for Lantern -*- lexical-binding: t; -*-

(use-package editorconfig
  :config
  (editorconfig-mode 1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package markdown-mode
  :mode (("README\.md\'" . gfm-mode)
         ("\.md\'" . markdown-mode)))

(use-package yaml-mode
  :mode "\.ya?ml\'")

(use-package json-mode
  :mode "\.json\'")

(use-package toml-mode
  :mode "\.toml\'")

(use-package dockerfile-mode
  :mode "Dockerfile\'")

(use-package web-mode
  :mode (("\.html?\'" . web-mode)
         ("\.tsx\'" . web-mode)
         ("\.jsx\'" . web-mode)))

(use-package typescript-mode
  :mode "\.ts\'")

(use-package rust-mode
  :mode "\.rs\'")

(use-package go-mode
  :mode "\.go\'")

(use-package eglot
  :hook ((python-mode . eglot-ensure)
         (js-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (web-mode . eglot-ensure)
         (go-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (yaml-mode . eglot-ensure))
  :custom
  (eglot-autoshutdown t)
  :config
  (add-to-list 'eglot-server-programs
               '((python-mode) . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((js-mode typescript-mode web-mode) . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((go-mode) . ("gopls")))
  (add-to-list 'eglot-server-programs
               '((rust-mode) . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs
               '((yaml-mode) . ("yaml-language-server" "--stdio"))))

(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(add-hook 'prog-mode-hook #'hs-minor-mode)
(add-hook 'prog-mode-hook #'subword-mode)

(provide 'lantern-prog)
