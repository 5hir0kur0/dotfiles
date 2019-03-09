;;; init.el --- Summary:
;; My init.el.
;;; Commentary:
;; Load customizations defined in code blocks inside config.org.
;;; Code:

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; This does not seem to work if I set it from within config.org.
;; set font
(add-to-list 'default-frame-alist '(font . "Monaco 13"))
;; use Noto as fallback font
(set-fontset-font "fontset-default" 'unicode
                  (font-spec :name "Noto Sans Mono"))

(defvar my/config-mtime-file-path (expand-file-name "~/.emacs.d/.config-last-compiled-time"))
(defvar my/config-file-path (file-truename (expand-file-name "~/.emacs.d/config.org")))
(defvar my/config-file-tangled (expand-file-name "~/.emacs.d/config.el"))

(require 'org)

(defun my/compile-init ()
  "Tangle and compile init file."
  (require 'ob-tangle)
  (org-babel-tangle-file my/config-file-path my/config-file-tangled 'emacs-lisp)
  (byte-compile-file my/config-file-tangled)
  ;; cause mtime of mtime-file to be changed
  (with-temp-file my/config-mtime-file-path
    (insert (format-time-string "%F %T%n"))))

(if (not (file-exists-p my/config-mtime-file-path))
    (progn
      (message "First run...")
      (require 'ob-tangle)
      (org-babel-tangle-file my/config-file-path my/config-file-tangled 'emacs-lisp)
      (load-file my/config-file-tangled)
      (my/compile-init))
  (unless (file-newer-than-file-p my/config-mtime-file-path my/config-file-path)
    (message "Compiling %s..." my/config-file-path)
    (my/compile-init))
  (load-file (byte-compile-dest-file my/config-file-tangled)))

(provide 'init)
;;; init.el ends here
