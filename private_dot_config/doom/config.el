;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; GENERAL SETTINGS ;;;

(setq user-full-name "Justin Jung"
      user-mail-address "justin@bustinbung.com")

; New emacsclient opens in main workspace
(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override "main"))

;;; DISPLAY OPTIONS ;;;

(setq doom-font (font-spec :family "Monaspace Argon Var" :size 16 :width 'Regular)
      doom-variable-pitch-font (font-spec :family "Noto Sans" :size 13))

(setq doom-theme 'catppuccin)

(setq display-line-numbers-type 'relative
      scroll-margin 10)
(setq-default tab-width 4
	      indent-tabs-mode t)

; Disables scroll margin in specific buffer types
; From https://github.com/syl20bnr/spacemacs/issues/3098
(add-hook! '(messages-buffer-mode-hook
	    comint-mode-hook
	    vterm-mode-hook)
	  (setq-local scroll-margin 0))

;;; PACKAGE OPTIONS ;;;

;; whitespace

(after! whitespace
  (setq whitespace-line-column 80
	whitespace-style '(face lines-tail trailing indentation)))

;; treemacs

(after! treemacs
  (setq treemacs-position 'right))

;; org-mode

; Need to be set before org loads
(setq org-directory "~/Nextcloud/org"
      org-agenda-files (list "inbox.org" "agenda.org"
			     "projects.org" "notes.org"))

(after! org
  (org-clock-persistence-insinuate)
  (setq org-clock-persist t
	org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
			    (sequence "WAIT(w@/!)" "HOLD(h@/!)" "|" "KILL(k@/!)"))
	org-log-into-drawer "LOGBOOK"
	org-export-date-timestamp-format "%Y-%m-%d"
	+org-capture-todo-file "inbox.org"
	+org-capture-notes-file "notes.org"
	jj/keep-clock-running nil)
  (setq org-capture-templates
	`(("i" "Inbox" entry (file+headline +org-capture-todo-file "Inbox")
	  ,(concat "* TODO %?\n"
		   ":LOGBOOK:\n"
		   "CAPTURED: %U\n"
		   ":END:")
	  :prepend t)
	  ("n" "Notes" entry (file+headline +org-capture-notes-file "Notes")
	   ,(concat "* Note (%a)\n"
		    ":LOGBOOK:\n"
		    "CAPTURED: %U\n"
		    ":END:\n"
		    "%?")
	   :prepend t))))
(add-hook! 'org-clock-out-hook :append 'jj/clock-out-maybe)

;; org-roam

(after! org-roam
  (setq org-roam-directory (file-truename (concat org-directory "notes/"))
	org-roam-graph-link-hidden-types '("file" "http" "https"))
  (org-roam-db-autosync-mode))

;; org-expiry

(use-package! org-expiry
  :after org
  :init
  (setq org-expiry-created-property-name "CREATED"
	org-expiry-inactive-timestamps t))

;; dired-preview

(after! dired-preview
  (setq dired-preview-delay 0.3
	dired-preview-max-file-size (expt 2 20)
	dired-preview-ignored-extensions-regexp
        (concat "\\."
                "\\(gz\\|"
                "zst\\|"
                "tar\\|"
                "xz\\|"
                "rar\\|"
                "zip\\|"
                "iso\\|"
                "epub\\|"
                "\\)"))
  (dired-preview-global-mode 1))

;;; KEYBINDS ;;;

(map! :mode org-mode-map :desc "+jj/punch-in" :leader "m c p i" #'jj/punch-in)
(map! :mode org-mode-map :desc "+jj/punch-out" :leader "m c p o" #'jj/punch-out)
(map! :mode org-mode-map :desc "org-clock-update-time-maybe" :leader "m c u" #'org-clock-update-time-maybe)

(map! :mode org-mode-map :desc "org-roam-node-insert" :leader "m l m" #'org-roam-node-insert)
(map! :mode org-mode-map :desc "org-roam-buffer-toggle" :leader "o m" #'org-roam-buffer-toggle)

;;; FUNCTIONS ;;;

; Custom functions for clocking in and out
; From: https://doc.norang.ca/org-mode.html#Clocking
(defun jj/punch-in (arg)
  "Start continuous clocking and set default task."
  (interactive "p")
  (if (not (marker-position org-clock-default-task))
      (error "ERROR: Default task not set!"))
  (setq jj/keep-clock-running t)
  (save-restriction
    (widen)
    ;; Find tags on current task
    (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
        (org-clock-in '(16))
      (jj/clock-in-default-task))))

(defun jj/punch-out ()
  (interactive)
  (setq jj/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-remove-restriction-lock))

(defun jj/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun jj/clock-in-parent-task ()
  "Move point to the parent (project) task if any and clock in"
  (let ((parent-task))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (not parent-task) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (if parent-task
            (org-with-point-at parent-task
              (org-clock-in))
          (when jj/keep-clock-running
            (jj/clock-in-default-task)))))))

(defun jj/clock-out-maybe ()
  (when (and jj/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (jj/clock-in-parent-task)))
