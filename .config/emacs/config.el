;;; -*- lexical-binding: t -*-

;;; Start configuring internal packages
(setq use-package-always-ensure nil)

(use-package emacs
  :config
  (setq default-directory "~/")

  (set-frame-font "JetBrainsMono" nil t)
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
    "s" 'diff-hl-stage-current-chunk))

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
(use-package evil-commentary
  :after evil
  :diminish
  :config (evil-commentary-mode +1))
(use-package evil-goggles
  :after evil
  :config
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))

(use-package consult
  :config (savehist-mode 1))
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
;;   (setq company-minimum-prefix-length     1
;;         company-idle-delay                0.1
;;         company-selection-wrap-around     t
;;         company-tooltip-align-annotations t
;;         company-frontends '(company-pseudo-tooltip-frontend ; show tooltip even for single candidate
;;                             company-echo-metadata-frontend))
;;   (define-key company-active-map (kbd "C-n") 'company-select-next)
;;   (define-key company-active-map (kbd "C-p") 'company-select-previous))
;; (use-package ido
;;   :config
;;   (ido-mode +1)
;;   (setq ido-everywhere           t
;;         ido-enable-flex-matching t
;;         ido-use-virtual-buffers  t))
;; (use-package ido-vertical-mode
;;   :config (ido-vertical-mode +1))
;; (use-package ido-completing-read+
;;   :config (ido-ubiquitous-mode +1))
;; (use-package flx-ido
;;   :config (flx-ido-mode +1))

(use-package org
  :hook ((org-mode . visual-line-mode)
         (org-mode . org-indent-mode))
  :config
  (add-to-list 'org-modules 'org-habit)
  (org-babel-do-load-languages 'org-babel-load-languages '((python     . t)
                                                           (shell      . t)
                                                           (emacs-lisp . t)))
  (defun org-db-sync ()
    (interactive)
    (setq org-agenda-files          (directory-files-recursively "~/vault/" "\\.org$")
          org-directory             "~/vault"))
  (org-db-sync)

  (setq org-agenda-files          (directory-files-recursively "~/vault/" "\\.org$")
        org-directory             "~/vault")
  (setq org-startup-folded        'content
        org-property-format       "%s %s"
        org-hide-emphasis-markers t)
  (setq org-todo-keywords         '((sequence "TODO(t)" "PENDING(p@)" "|" "DONE(d)" "CANCELLED(c@)"))
        org-todo-keyword-faces    '(("PENDING"   . +org-todo-onhold)
                                    ("CANCELLED" . +org-todo-cancel)))
  (setq org-log-done              'time
        org-log-reschedule        'note
        org-log-redeadline        'note
        org-log-into-drawer       "LOGBOOK"
        org-clock-into-drawer     "TIMEBOOK"
        org-agenda-log-mode-items '(closed clock state))

  (setf (cdr (assoc 'file org-link-frame-setup)) #'find-file))
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
  (org-roam-db-sync))
(use-package websocket
  :after org-roam)
(use-package org-roam-ui
  :after org-roam)

(use-package ledger-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.\\(h?ledger\\|journal\\|j\\)$" . ledger-mode))
  (setq ledger-mode-should-check-version            nil
        ledger-binary-path                          "hledger"
        ledger-report-native-highlighting-arguments '("--color=always")
        ledger-default-date-format                  ledger-iso-date-format
        ledger-report-auto-width                    nil
        ledger-report-links-in-register             nil))

(use-package magit
  :config 
  (add-hook 'with-editor-mode-hook #'evil-insert-state)
  (add-hook 'magit-mode-hook (lambda () (setq left-fringe-width 20
                                              right-fringe-width 4)))
  (setq magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1))
(use-package diff-hl
  :config
  (global-diff-hl-mode)
  (diff-hl-flydiff-mode)
  (setq diff-hl-flydiff-delay       0.5
        diff-hl-show-staged-changes nil)
  (setq diff-hl-margin-symbols-alist '((insert  . "┃") (change  . "┃") (delete    . "-")
                                       (unknown . "┆") (ignored . "i") (reference . " ")))
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

; (use-package autorevert
;   :ensure nil
;   :config
;   (global-auto-revert-mode +1)
;   (setq auto-revert-interval                2
;         auto-revert-check-vc-info           t
;         global-auto-revert-non-file-buffers t
;         auto-revert-verbose                 nil))
; (use-package eldoc
;   :ensure nil
;   :diminish eldoc-mode
;   :config (setq eldoc-idle-delay 0.4))
; (use-package ediff
;   :ensure nil
;   :config
;   (setq ediff-window-setup-function #'ediff-setup-windows-plain)
;   (setq ediff-split-window-function #'split-window-horizontally))
;
; (use-package dired
;   :ensure nil
;   :config
;   (setq delete-by-moving-to-trash t)
;   (eval-after-load "dired"
;     #'(lambda ()
;         (put 'dired-find-alternate-file 'disabled nil)
;         (define-key dired-mode-map (kbd "RET") #'dired-find-alternate-file))))
;
; (use-package company
;   :diminish company-mode
;   :hook (prog-mode . company-mode)
;   :config
;   (setq company-minimum-prefix-length 1
;         company-idle-delay 0.1
;         company-selection-wrap-around t
;         company-tooltip-align-annotations t
;         company-frontends '(company-pseudo-tooltip-frontend ; show tooltip even for single candidate
;                             company-echo-metadata-frontend))
;   (define-key company-active-map (kbd "C-n") 'company-select-next)
;   (define-key company-active-map (kbd "C-p") 'company-select-previous))
;
; ;; (use-package flycheck :config (global-flycheck-mode +1))
;
; (use-package exec-path-from-shell
;   :config (when (memq window-system '(mac ns x))
;             (exec-path-from-shell-initialize)))
