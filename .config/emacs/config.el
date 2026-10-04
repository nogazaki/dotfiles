;;; -*- lexical-binding: t -*-

;;; Start configuring internal packages
(setq use-package-always-ensure nil)

(use-package emacs
  :config
  (setq default-directory "~/")

  (set-frame-font "JetBrainsMono 12" nil t)
  (setq nerd-icons-font-family "SymbolsNerdFont")
  (setq frame-resize-pixelwise t
        inhibit-startup-screen t
        ring-bell-function     'ignore)

  (recentf-mode 1)
  (setopt use-short-answers t)

  (column-number-mode               1)
  (global-display-line-numbers-mode 1)
  (setq-default display-line-numbers-type  'relative
                display-line-numbers-width 3)

  (setq auto-window-vscroll             nil
        scroll-preserve-screen-position t
        scroll-margin                   10
        scroll-conservatively           101)

  (modify-all-frames-parameters '((internal-border-width . 8)))
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (savehist-mode)

  (setq-default tab-width        4
                indent-tabs-mode nil))
(use-package delsel
  :config (delete-selection-mode 1))
(use-package elec-pair
  :hook (prog-mode . electric-pair-mode))
(use-package files
  :config
  (setq confirm-kill-processes nil
        create-lockfiles       nil ; don't create .# files (crashes 'npm start')
        make-backup-files      nil))
(use-package fringe
  :config
  (fringe-mode 4))
(use-package mwheel
  :config (setq mouse-wheel-progressive-speed nil
                mouse-wheel-scroll-amount     '(2 ((shift) . 1))))
(use-package paren
  :init (setq show-paren-delay 0)
  :config (show-paren-mode +1))
(use-package scroll-bar
  :config (scroll-bar-mode -1))
(use-package simple
  :config (column-number-mode 1))
(use-package whitespace
  :hook (before-save . whitespace-cleanup))

;;; Start configuring third-party packages
(setq use-package-always-ensure t)

(use-package general
  :after (diff-hl magit org projectile)
  :config
  (general-create-definer projectile-key-def
    :prefix "SPC s")
  (projectile-key-def
    :keymaps 'normal
    "f" 'projectile-find-file)

  (general-create-definer orgmode-key-def
    :prefix "SPC o")
  (orgmode-key-def
    :keymaps 'normal
    "a" 'org-agenda
    "t s" 'org-narrow-to-subtree
    "t S" 'widen)

  (general-create-definer git-key-def
    :prefix "SPC g")
  (git-key-def
    :keymaps 'normal
    "g" 'magit-status
    "s" 'diff-hl-stage-current-chunk
    :keymaps 'visual
    "s" 'diff-hl-stage-some))

(use-package dashboard
  :config
  (setq dashboard-vertically-center-content t)
  (setq dashboard-startup-banner   'logo
        dashboard-projects-backend 'projectile
        dashboard-items            '((projects . 5)
                                     (recents  . 5)
                                     (agenda   . 5)))
  (dashboard-setup-startup-hook))
(use-package doom-modeline
  :init (doom-modeline-mode 1))
(use-package highlight-numbers
  :hook (prog-mode . highlight-numbers-mode))
(use-package highlight-escape-sequences
  :hook (prog-mode . hes-mode))

(use-package evil
  :diminish undo-tree-mode
  :hook (after-init . evil-mode)
  :init
  (setq evil-shift-width     4
        evil-want-C-u-scroll t
        evil-want-C-i-jump   nil
        evil-want-keybinding nil)
  :config
  (unless (display-graphic-p)
    (add-hook 'evil-insert-state-entry-hook (lambda () (send-string-to-terminal "\033[5 q")))
    (add-hook 'evil-insert-state-exit-hook  (lambda () (send-string-to-terminal "\033[2 q")))))
(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-company-use-tng nil)
  (evil-collection-init))
(use-package evil-org
  :after org
  :hook (org-mode . (lambda () evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))
(use-package evil-commentary
  :after evil
  :diminish
  :config (evil-commentary-mode +1))
(use-package evil-goggles
  :after evil
  :config
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))

(use-package consult)
(use-package projectile
  :config (projectile-mode +1))
(use-package vertico
  :config
  (setq vertico-cycle  t
        vertico-resize nil)
  (vertico-mode 1))
(use-package marginalia
  :config (marginalia-mode 1))
(use-package orderless
  :config (setq completion-styles '(orderless flex)))
(use-package company
  :diminish company-mode
  :hook ((prog-mode . company-mode)
         (ledger-mode . company-mode)))

(use-package org
  :hook ((org-mode . visual-line-mode)
         (org-mode . org-indent-mode))
  :config
  (add-to-list 'org-modules 'org-habit)

  (setq org-directory             "~/vault"
        org-startup-folded        'content
        org-property-format       "%s %s"
        org-hide-emphasis-markers t
        org-src-fontify-natively  t)

  (defun org-db-sync () (interactive) (setq org-agenda-files (directory-files-recursively "~/vault/" "\\.org$")))
  (org-db-sync)

  (setq org-todo-keywords         '((sequence "TODO(t)" "STARTED(s)" "PENDING(p@)" "|" "DONE(d)" "CANCELLED(c@)"))
        org-todo-keyword-faces    '(("STARTED"   . ((t (:inherit (bold success org-todo)))))
                                    ("PENDING"   . ((t (:inherit (bold warning org-todo)))))
                                    ("CANCELLED" . ((t (:inherit (bold error org-todo)))))))
  (setq org-log-done              'time
        org-log-reschedule        'note
        org-log-redeadline        'note
        org-log-into-drawer       "LOGBOOK"
        org-clock-into-drawer     "TIMEBOOK"
        org-agenda-log-mode-items '(closed clock state))

  (setq org-refile-targets '((org-agenda-files :maxlevel . 3)
                             (nil :maxlevel . 3)))

  (setq org-src-preserve-indentation t)
  (org-babel-do-load-languages 'org-babel-load-languages '((python     . t)
                                                           (shell      . t)
                                                           (emacs-lisp . t)))

  (setf (cdr (assoc 'file org-link-frame-setup)) #'find-file))
(use-package org-contrib)
(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode))
(use-package org-appear
  :after org
  :hook (org-mode . org-appear-mode)
  :config (setq org-appear-autolinks t))
(use-package org-roam
  :after org
  :config
  (setq org-roam-directory         org-directory
        org-roam-dailies-directory "01_fleeting"
        org-roam-db-autosync-mode  t)
  (advice-add 'org-roam-db-sync :after #'(lambda (&rest _args) (org-db-sync)))
  (org-roam-db-sync))
(use-package websocket
  :after org-roam)
(use-package org-roam-ui
  :after org-roam)
(use-package ox-extra
  :ensure nil
  :after org-contrib
  :config
  (ox-extras-activate '(latex-header-blocks ignore-headlines)))
(use-package ox-latex
  :ensure nil
  :after org
  :config
  (unless (boundp 'org-latex-classes)
    (setq org-latex-classes nil)))

(use-package ledger-mode
  :custom-face
  (ledger-font-payee-cleared-face ((t (:inherit (font-lock-string-face)))))
  :config
  (add-to-list 'auto-mode-alist '("\\.\\(h?ledger\\|journal\\|j\\)$" . ledger-mode))
  (setq ledger-mode-should-check-version            nil
        ledger-binary-path                          "hledger"
        ledger-report-native-highlighting-arguments '("--color=always")
        ledger-default-date-format                  ledger-iso-date-format
        ledger-report-auto-width                    nil
        ledger-report-links-in-register             nil
        ledger-post-amount-alignment-column         42))

(use-package magit
  :config
  (add-hook 'with-editor-mode-hook #'evil-insert-state)
  (add-hook 'magit-mode-hook (lambda () (setq left-fringe-width 20
                                              right-fringe-width 4)))
  (setq magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1))
(use-package diff-hl
  :init
  (global-diff-hl-mode)
  :hook ((magit-pre-refresh-hook . diff-hl-magit-pre-refresh)
         (magit-post-refresh-hook . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode 1)
  (setq diff-hl-flydiff-delay 0.5)
  ;; (setq diff-hl-margin-symbols-alist '((insert  . "┃") (change  . "┃") (delete    . "-")
  ;;                                      (unknown . "┆") (ignored . "i") (reference . " ")))
  (custom-set-faces '(diff-hl-margin-insert ((t (:inherit diff-hl-insert :foreground "unspecified-bg" :inverse-video t))))
                    '(diff-hl-margin-change ((t (:inherit diff-hl-change :foreground "unspecified-bg" :inverse-video t))))
                    '(diff-hl-margin-delete ((t (:inherit diff-hl-delete :foreground "unspecified-bg" :inverse-video t))))))

(use-package which-key
  :diminish which-key-mode
  :config
  (which-key-mode +1)
  (setq which-key-idle-delay           0.4
        which-key-idle-secondary-delay 0.4))

(use-package diminish
  :demand t)
