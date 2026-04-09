;;; -*- lexical-binding: t -*-

;;; Garbage collection
(let ((threshold      100000000)
      (original-alist file-name-handler-alist))
  (setq gc-cons-threshold       most-positive-fixnum
        gc-cons-percentage      0.6
        site-run-file           nil
        file-name-handler-alist nil)

  (add-hook 'emacs-startup-hook
            (lambda () (setq gc-cons-percentage      0.1
                             gc-cons-threshold       threshold
                             file-name-handler-alist original-alist)))
  (add-hook 'minibuffer-setup-hook
            (lambda () (setq gc-cons-threshold (* threshold 2))))
  (add-hook 'minibuffer-exit-hook
            (lambda () (garbage-collect) (setq gc-cons-threshold threshold))))

;;; Emacs 28+ (native-comp)
(when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
  (progn (add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))
         (setq package-native-compile                   t
               native-comp-deferred-compilation         t
               native-comp-async-report-warnings-errors nil)))

;;; Setting up the package manager. Install if missing.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-and-compile (setq package-enable-at-startup nil))
(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org"   . "https://orgmode.org/elpa/"))
(package-initialize)

;;; Visual
(use-package catppuccin-theme
  :ensure t
  :demand t
  :config
  (load-theme 'catppuccin :no-confirm)
  (set-face-attribute 'highlight nil :foreground 'unspecified))

(use-package cus-edit
  :config (setq custom-file (expand-file-name ".cus-edit.el" user-emacs-directory)))

(load-file (expand-file-name "config.el" user-emacs-directory))
(provide 'init)
