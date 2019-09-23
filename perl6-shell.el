;;; perl6-shell.el --- create a interpreter for Perl 6 -*- lexical-binding: t; -*-

;; This is free and unencumbered software released into the public domain.
;; Copyright (C) 2019  Yauhen Makei <yauhen.makei@gmail.com>

;; Author: Yauhen Makei <yauhen.makei@gmail.com>
;; Maintainer: yauhen.makei@gmail.com
;; URL: https://github.com/ymakei/perl6-shell-mode
;; Keywords: processes
;; Version: 0.1-git
;; Package-Requires: ((emacs "24.4") (pkg-info "0.1"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; GNU Emacs 24 major mode for interactive run Perl 6 code.

;;; Code:

(declare-function pkg-info-version-info "pkg-info" (library))

(defgroup perl6-shell nil
  "Run an outside Perl 6 in a Emacs buffer."
  :group 'perl6
  :version "24.4")

(require 'comint)
; (require 'compile)
(require 'perl6-mode)

(defcustom perl6-shell-interpreter "perl6"
  "Default Perl 6 interpreter command."
  :type 'string
  :group 'perl6-shell)

(defcustom perl6-arguments '()
  "Commandline arguments to pass to `perl6'"
  :type 'list
  :group 'perl6-shell)

(defvar perl6-shell-mode-map
  (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
    ;; example definition
    (define-key map "\t" 'completion-at-point)
    map)
  "Basic mode map for `run-perl6'.")

(defvar perl6-shell-prompt-regexp "> "
  "Prompt for `run-perl6'.")

(defun perl6-shell--initialize ()
  "Helper function to initialize `perl6'."
  (setq comint-process-echoes t)
  (setq comint-use-prompt-regexp t))

(define-derived-mode perl6-shell-mode comint-mode "Inferior Perl 6"
  "Major mode for `run-perl6'.

\\{perl6-shell-mode-map}
"
  (setq comint-prompt-regexp perl6-shell-prompt-regexp
        comint-prompt-read-only t
        comint-process-echoes nil)
  ;; this makes it so commands like M-{ and M-} work.
  (set (make-local-variable 'paragraph-separate) "\\'")
  (set (make-local-variable 'font-lock-defaults) '(perl6-font-lock-keywords t))
  (set (make-local-variable 'paragraph-start) perl6-shell-prompt-regexp)
  (add-hook 'perl6-mode-hook 'perl6-shell--initialize))

;;;###autoload
(defalias 'perl6 'run-perl6)

;;;###autoload
(defun run-perl6 ()
  "Run an inferior instance of `perl6' inside Emacs."
  (interactive)
  (let* ((perl6-program perl6-shell-interpreter)
         (buffer (comint-check-proc "*perl6*")))
    (when (not (get-buffer "*perl6*"))
      (with-current-buffer (get-buffer-create "*perl6*")))
    (pop-to-buffer (get-buffer "*perl6*"))
    ;; create the comint process if there is no buffer.
    (unless buffer
      (apply 'make-comint-in-buffer "perl6" buffer
             perl6-program perl6-arguments)
      (perl6-shell-mode))))

;;;###autoload
(eval-after-load 'perl6-mode
  '(progn
     (define-key perl6-mode-map (kbd "C-c C-z") #'run-perl6)))

(provide 'perl6-shell)

;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:

;;; perl6-shell.el ends here