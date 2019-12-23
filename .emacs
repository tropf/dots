(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(package-initialize)

;; workaround until emacs 26.3
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

(if (not (package-installed-p 'use-package))
    (progn
      (package-refresh-contents)
      (package-install 'use-package)))

(require 'use-package)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cmake-tab-width 4)
 '(indent-tabs-mode nil)
 '(package-selected-packages
   (quote
    (company-php web-mode helm cmake-mode projectile evil-magit magit-evil magit key-chord company company-c-headers flycheck-rtags rtags cmake-ide flycheck evil-surround beacon evil-escape flymd markdown-preview-mode markdown-mode company-irony irony gnu-elpa-keyring-update evil use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; no visual bell
(setq visible-bell t)

;; no blinking cursor
(setq blink-cursor-mode nil)

;; linenumbers everywhere
(global-linum-mode t)

;; use firefox by default
(setq-default browse-url-browser-function 'browse-url-firefox)

;; tab width 4
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 4)
(setq-default cperl-indent-level 4)
(setq-default backward-delete-char-untabify-method 'hungry)
(setq indent-line-function 'insert-tab)
(add-hook 'text-mode-hook
          '(lambda ()
             (setq indent-tabs-mode nil)
             (setq tab-width 4)))

;; save cursor position
(save-place-mode 1)

;; global auto closing parenthesis
(electric-pair-mode 1)

;; custom startup message
(defun display-startup-echo-area-message ()
  "Create a custom message on startup in the minibuffer."
  (message "ready."))

(defun generate-startup-buffer ()
  "Create custom startup buffer and set is as default for startup."
  (let ((bufnam (generate-new-buffer-name "*tropfstart*")))
    (generate-new-buffer bufnam)
    (switch-to-buffer bufnam)
    (setq-local buffer-undo-list t)
    (insert "fun content")
    (setq-local buffer-read-only t)
    bufnam))

(setq-default initial-buffer-choice t)
(setq-default initial-scratch-message ";; Initial Setup
;; =============
;; ```
;; M-x irony-install-server
;; M-x rtags-install
;; ```
;;
;; Keybinds
;; ========
;; | Keys        | Function        | Context       |
;; |-------------|-----------------|---------------|
;; | C-c C-c ... | Markdown stuff  | markdown-mode |
;; | C-c C-d     | Realign Table   | markdown-mode |
;; | HH          | make            | cmake project |
;; | HJ          | cmake debug     | cmake project |
;; | HC          | cmake (vanilla) | cmake project |
;; | HI          | toggle .cc/.h   | cmake project |
;; | C-SPC       | open completion | insert mode   |
;;
;; TODO
;; ====
;; - toggle header/implementation/test
;; - debugger keybinds
;; - cmake guess dirs more often (on window focus switch)

")

(defun find-top-cmake (dir)
  "Find the highest level directory above DIR with a CMakeLists.txt file."
  (if (equal "/" dir)
      nil
    (if (find-top-cmake (file-truename (concat dir "/..")))
        (find-top-cmake (file-truename (concat dir "/..")))
      (if (member "CMakeLists.txt" (directory-files dir))
          dir
        nil))))

(defun cmake-ide-guess-dirs ()
  "Guess the current CMake project directory.
Will set the build and project directories accordingly.
Uses the highest level directory above the current one
containing a CMakeLists.txt file."
  (interactive)
  (setq cmake-ide-project-dir (find-top-cmake default-directory))
  (setq cmake-ide-build-dir (concat (file-name-as-directory (find-top-cmake default-directory)) "build")))

(defun generate-append-list (head followers)
  "Append each element of FOLLOWERS to HEAD in an individual string."
  (when followers
    (cons (concat head (car followers)) (generate-append-list head (cdr followers)))))

(defun multiply-two-lists (l1 l2)
  "Build all combinations of elements (strings) from list L1 and list L2."
  (when l1
    (append (generate-append-list (car l1) l2) (multiply-two-lists (cdr l1) l2))))

(defun multiply-lists (l1 listoflists)
  "Build all combinations of elements (strings) from L1 and the lists in LISTOFLISTS."
  (if listoflists
      (multiply-lists (multiply-two-lists l1 (car listoflists)) (cdr listoflists))
    l1))

(defun generate-append-lists (followerslist)
  "Build all combinations of FOLLOWERSLIST elements (which are lists)."
  (multiply-lists '("") followerslist))

(defun try-find-file (f)
  "Try to find the file F in a buffer.  Otherwise does nothing."
  (when f
    (when (file-exists-p f)
      (find-file f))))

(defun try-find-files (filelist)
  "Try to find any file in FILELIST in a buffer.  Otherwise does nothing."
  (unless (try-find-file (car filelist))
    (try-find-files (cdr filelist))))

(defun read-lines (filePath)
  "Return a list of lines of a file at FILEPATH."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))

(defun get-match-list (regex lines)
  "Return group 1 of the first line in LINES matching REGEX."
  (if lines
    (if (string-match regex (car lines))
        (match-string 1 (car lines))
      (get-match-list regex (cdr lines)))
    nil))

(defun get-cmake-project-name ()
  "Read the current cmake project name.  Requires cmake-ide-build-dir to be set."
  (get-match-list "^CMAKE_PROJECT_NAME\\(?::[^=]*\\)?=\\(.*\\)$" (read-lines (concat (file-name-as-directory cmake-ide-build-dir) "CMakeCache.txt"))))

(defun implode (glue parts)
  "Put all PARTS together, inserting GLUE between them."
  (if (cdr parts)
    (concat (car parts) glue (implode glue (cdr parts)))
    (if parts
        (car parts)
      "")))

(defun get-as-subdirs (path)
  "Return a list of relative paths, each working from one of the parent directories of PATH."
  (unless (string= path "")
  (cons path (get-as-subdirs (implode "/" (cdr (split-string path "/")))))))

(defun remove-file-extension (path)
  "Return PATH without file extension."
  (replace-regexp-in-string "\\.[^.]*$" "" path))

(defun list-filter (f l)
  "Apply function F to each list element of L."
  (when l
    (cons
     (funcall f (car l))
     (list-filter f (cdr l)))))

(defun cmake-ide-toggle-impl-header ()
  "Custom toggle between implementation and header file."
  (interactive)
  (let ((ext (file-name-extension (buffer-file-name (window-buffer (minibuffer-selected-window))))))
    (when (member ext '("h" "hh" "hxx" "H" "hpp"))
      (cmake-ide-find-implementation))
    ;;(string-match "^.*\\.\([^.]*\)$" f)
    (when (member ext '("cc" "cxx" "cpp" "C" "c"))
      (cmake-ide-find-header))))

(defun cmake-ide-find-header ()
  "Try to find the corresponding header file to the current buffer."
  (interactive)
  (try-find-files
   (generate-append-lists (list
                           (list (file-name-as-directory (find-top-cmake cmake-ide-build-dir)))
                           '("inc/" "include/")
                           (list "" (concat (get-cmake-project-name) "/"))
                           (list-filter #'remove-file-extension (get-as-subdirs (buffer-file-name (window-buffer (minibuffer-selected-window)))))
                           '(".")
                           '("h" "hpp" "hxx" "H" "hh")))))

(defun cmake-ide-find-implementation ()
  "Try to find the corresponding implementation file to the current buffer."
  (interactive)
  (try-find-files
   (generate-append-lists (list
                           (list (file-name-as-directory (find-top-cmake cmake-ide-build-dir)))
                           '("src/" "lib/")
                           (list "" (concat (get-cmake-project-name) "/"))
                           (list-filter #'remove-file-extension (get-as-subdirs (buffer-file-name (window-buffer (minibuffer-selected-window)))))
                           '(".")
                           '("cc" "c" "cpp" "cxx" "C")))))

(use-package color-theme-modern
  :config
  (load-theme 'cobalt t t)
  (enable-theme 'cobalt)
  :ensure t)

(defun cmake-ide-compile-with-jump ()
  "Call cmake-ide-compile and place point at the bottom of the compilation log."
  (interactive)
  (cmake-ide-compile)
  (when (get-buffer-window "*compilation*")
    (set-window-point
     (get-buffer-window "*compilation*")
     (+ 1 (buffer-size (get-buffer "*compilation*"))))))

(use-package evil
  :ensure t
  :config
  (evil-mode 1)
  (evil-set-initial-state 'term-mode 'emacs)
;;  (define-key evil-insert-state-map (kbd "M-V") 'evil-visual-paste)
;;  (define-key evil-insert-state-map (kbd "C-SPC") 'company-complete)

  (evil-define-key 'insert 'global
    (kbd "M-V") 'evil-paste-before
    (kbd "C-SPC") 'company-complete)

  (evil-define-key 'normal 'global
    (kbd "H") nil
    (kbd "HH") 'cmake-ide-compile-with-jump
    (kbd "HC") 'cmake-ide-run-cmake
    (kbd "HJ") 'cmake-ide-configure-debug
    (kbd "HI") 'cmake-ide-toggle-impl-header)
  )

;; evil-escape-mode
(use-package evil-escape
  :config
  (evil-escape-mode 1)
  (setq-default evil-escape-key-sequence "jk")
  (setq-default evil-escape-delay 1.0)
  :ensure t)

;; evil multi-cursor TODO

;; code folding
(add-hook 'prog-mode-hook #'hs-minor-mode)

(use-package gnu-elpa-keyring-update
  :ensure t)

;; requires once: irony-install-server
(use-package irony
  :config
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  :ensure t)

(use-package company
  :config
  (add-hook 'after-init-hook 'global-company-mode)
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1)
  (setq company-selection-wrap-around t)
  (company-tng-configure-default)
  :ensure t)

(use-package company-irony
  :config
  (eval-after-load 'company '(add-to-list 'company-backends 'company-irony))
  :ensure t)

(use-package company-c-headers
  :config
  (eval-after-load 'company '(add-to-list 'company-backends 'company-c-headers))
  :ensure t)

(use-package company-php
  :config
  (add-hook 'web-mode-hook
            '(lambda ()
               (require 'company-php)
               (company-mode t)
               (add-to-list 'company-backends 'company-ac-php-backend)))
  :ensure t)

(use-package helm
  :config
  (global-set-key (kbd "M-x") 'helm-M-x)
  :ensure t)

;; requires system binary: pandoc
(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
    ("\\.md\\'" . markdown-mode)
    ("\\.markdown\\'" . markdown-mode))
  :config
  (setq-default markdown-list-indent-width 4)
  (setq-default markdown-indent-on-enter 'indent-and-new-item)
  :init (setq markdown-command "pandoc"))

(use-package flycheck
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode)
  :ensure t)

;; requires run once: rtgas-install
(use-package rtags
  :ensure t)

(use-package flycheck-rtags
  :ensure t)

(defun cmake-ide-configure-debug ()
  "Run cmake to create a Debug build."
  (interactive)
  (setq cmake-ide-cmake-args (append cmake-ide-cmake-args '("-DCMAKE_BUILD_TYPE=Debug")))
  (cmake-ide-run-cmake))

(use-package cmake-ide
  :init
  :config
  (cmake-ide-setup)
  (add-hook 'c-mode-hook 'cmake-ide-guess-dirs)
  (add-hook 'c++-mode-hook 'cmake-ide-guess-dirs)
  (add-hook 'find-file-hook 'cmake-ide-guess-dirs)
  :after (rtags evil key-chord)
  :ensure t)

(use-package beacon
  :config
  (beacon-mode 1)
  :ensure t)

(use-package key-chord
  :config
  (setq key-chord-two-keys-delay 3)
  (key-chord-mode 1)
  :ensure t)

(use-package magit
  :ensure t)

(use-package evil-magit
  :ensure t)

(use-package projectile
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  :ensure t)

(use-package cmake-mode
  :ensure t)

(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.php?\\'" . web-mode))
  (setq web-mode-engines-alist
      '(("php"    . "\\.php\\'")
        ("html"  . "\\.html\\'"))
      web-mode-enable-current-column-highlight t
      web-mode-enable-current-element-highlight t)
  :ensure t)

(provide '.emacs)
;;; .emacs ends here
