;; It's in alt position on the native keyboard, annoying
(setq mac-command-modifier 'meta)
(setq mac-control-modifier 'ctrl)
;; for real keyboards
(setq mac-option-modifier 'meta)

;;; can't find a better way to do this yet
(setq exec-path
      (cons "/usr/local/bin"
            (split-string
             (or (getenv "PATH") "")
             ":")))

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/.emacs.d/el-get-user/recipes")

;; set local recipes, el-get-sources should only accept PLIST element

(setq
 my:el-get-packages
 '(el-get
   switch-window
   zencoding-mode
   avy
   es-mode
   paredit
   clj-refactor
   cider
   less-css-mode
   markdown-mode
   handlebars-mode
   magit
   coffee-mode
   js2-mode
   company-mode
   tuareg-mode
   yasnippet
   pianobar
   color-theme
   aggressive-indent-mode
   org-tree-slide
   ag
   projectile
   helm
   helm-ag
   helm-ls-git
   omake-syntax
   helm-projectile
   ))



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cljr-favor-prefix-notation nil)
 '(el-get-sources
   (quote
    ((:name cider :checkout "v0.13.0")
     (:name clj-refactor :checkout "2.2.0")
     (:name magit :checkout "2.10.3")
     (:name omake-syntax
            :description "OMake syntax"
            :type github
            :pkgname "emacsmirror/omake"
            :compile "\\.el$"
            :prepare (progn
                       (autoload 'omake-mode "omake-mode" "OMake editing mode" t)
                       (add-to-list 'auto-mode-alist '("OMake\\(?:file\\|root\\)\\'" . omake-mode))
                       (add-to-list 'auto-mode-alist '("\\.om\\'" . omake-mode))
                       )))))
 '(js-indent-level 2)
 '(js2-bounce-indent-p t)
 '(js2-mode-show-parse-errors nil)
 '(js2-strict-missing-semi-warning nil)
 '(js2-strict-trailing-comma-warning nil))

;; install new packages and init already installed packages
(el-get 'sync my:el-get-packages)

;; elpas
(el-get-bundle elpa:direnv)
(el-get-bundle elpa:async)
(el-get-bundle elpa:inflections)
(el-get-bundle elpa:queue)
(el-get-bundle elpa:better-defaults)

(setq pianobar-username (getenv "PIANOBAR_USER"))
(setq pianobar-password (getenv "PIANOBAR_PASSWORD"))
(setq pianobar-station "7")

;;; bindings

;; override projectile commands with helm-projectile ones
(projectile-global-mode)
(setq projectile-completion-system 'helm)
(require 'helm-projectile)
(helm-projectile-on)

(global-set-key (kbd "C-'") 'avy-goto-char-2)
(global-set-key (kbd "C-M-'") 'helm-projectile-ag)
(global-set-key (kbd "C-\"") 'avy-goto-char-2)

;;; the logitech scrolling workaround
(global-set-key [mouse-3] nil)

; otherwise projectile is only loaded in certain modes
(global-set-key (kbd "C-c p p") 'helm-projectile-switch-project)

(require 'color-theme)
;; (color-theme-lawrence)
(color-theme-emacs-nw)

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(defvar my-font)

(defun font-input ()
  (setq my-font "-*-Input-normal-normal-ultracondensed-*-12-*-*-*-m-0-iso10646-1")
  (setq mac-allow-anti-aliasing t)
  (set-default-font my-font)
  (add-to-list 'default-frame-alist `(font . ,my-font)))

(defun font-terminus ()
  (setq my-font "-*-Terminus (TTF)-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")
  (setq mac-allow-anti-aliasing nil)
  (set-default-font my-font)
  (add-to-list 'default-frame-alist `(font . ,my-font)))

(defun font-andale ()
  (setq my-font "-*-Andale Mono-normal-normal-normal-*-13-*-*-*-m-0-iso10646-1")
  (setq mac-allow-anti-aliasing nil)
  (set-default-font my-font)
  (add-to-list 'default-frame-alist `(font . ,my-font)))

(defun font-monaco ()
  (setq my-font "-*-Monaco-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1")
  (setq mac-allow-anti-aliasing nil)
  (set-default-font my-font)
  (add-to-list 'default-frame-alist `(font . ,my-font)))

(font-andale)
;; (font-monaco)
;; (font-terminus)
;; (font-input)

(require 'thingatpt)
(defun custom-capf ()
  "Complete the symbol at point."
  (let ((sap (symbol-at-point)))
    (when (and sap)
      (let ((bounds (bounds-of-thing-at-point 'symbol)))
        (list (car bounds) (cdr bounds)
              (dabbrev-get-candidates (symbol-name sap) t))))))

;; http://emacswiki.org/emacs/anything-dabbrev-expand.el
(require 'dabbrev)
(defun dabbrev-get-candidates (abbrev &optional all)
  (let ((dabbrev-check-other-buffers t))
    (dabbrev--reset-global-variables)
    (dabbrev--find-all-expansions abbrev nil)))

(defvar lispy-js-map)
(setq lispy-js-map
      (let ((map (make-sparse-keymap)))
        (define-key map (kbd "{") 'paredit-open-curly)
        (define-key map (kbd "(") 'paredit-open-round)
        (define-key map (kbd "[") 'paredit-open-square)
        (define-key map (kbd "}") 'paredit-close-curly)
        (define-key map (kbd ")") 'paredit-close-round)
        (define-key map (kbd "]") 'paredit-close-square)
        (define-key map (kbd "<C-tab>") 'company-complete)
        (define-key map (kbd "<M-SPC>") 'company-complete)
        (define-key map (kbd "M-u") 'upcase-word-at-point)
        (define-key map (kbd "M-l") 'downcase-word-at-point)
        (define-key map (kbd "C-c -") 'camelscore-word-at-point)
        (define-key map (kbd "M-;") 'comment-dwim)
        map))

(define-minor-mode lispy-js-mode
  "Bindings for a presentation using coffeescript"
  ;; The initial value.
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " lispy-js"
  ;; The minor mode bindings.
  :keymap lispy-js-map
  :group 'gary)

;;; programming

(add-hook 'prog-mode-hook 'whitespace-mode)
;; (add-hook 'prog-mode-hook 'idle-highlight-mode)
(add-hook 'prog-mode-hook 'hl-line-mode)

(add-hook 'clojure-mode-hook 'paredit-mode)

(setq cider-prompt-for-symbol nil)
(setq cider-repl-display-help-banner nil)
(setq cider-font-lock-dynamically nil)

(defun my-paredit-nonlisp ()
  "Turn on paredit mode for non-lisps."
  (interactive)
  (set (make-local-variable 'paredit-space-for-delimiter-predicates)
       '((lambda (endp delimiter) nil)))
  (paredit-mode 1))

(require 'yasnippet)
(yas-reload-all)

(add-hook 'js-mode-hook
          (lambda ()
            (push '("function" . ?ƒ) prettify-symbols-alist)
            (prettify-symbols-mode)
            (set (make-local-variable 'company-backends) '(company-capf))
            (set (make-local-variable 'completion-at-point-functions) '(custom-capf))
            (set (make-local-variable 'completion-styles) '(substring))
            (setq completion-category-overrides '((buffer (styles substring))))
            (set (make-local-variable 'company-dabbrev-downcase) nil)
            (company-mode)
            (yas-minor-mode)
            ;; earlier minor mode maps win
            (lispy-js-mode)
            (projectile-mode)
            (my-paredit-nonlisp)
            ))

(add-to-list 'auto-mode-alist '("\\.js" . js2-mode))

(require 'js2-mode)

(define-key js2-mode-map (kbd "M-,") 'pop-tag-mark)

(add-hook 'nrepl-connected-hook
          (defun pnh-clojure-mode-eldoc-hook ()
            (add-hook 'clojure-mode-hook 'turn-on-eldoc-mode)))

(setq whitespace-style '(face trailing lines-tail tabs))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
;; (add-hook 'emacs-lisp-mode-hook 'elisp-slime-nav-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)

(define-key emacs-lisp-mode-map (kbd "C-c v") 'eval-buffer)

(define-key read-expression-map (kbd "TAB") 'lisp-complete-symbol)
(define-key lisp-mode-shared-map (kbd "RET") 'reindent-then-newline-and-indent)

(global-set-key (kbd "M-x") 'helm-M-x)
; open helm buffer inside current window, not occupy whole other window
(setq helm-split-window-in-side-p t)

(global-set-key (kbd "C-c l") 'org-store-link)
(setq org-return-follows-link 't)

(defun toggle-fullscreen ()
  "Toggle full screen on X11"
  (interactive)
  (when (eq window-system 'x)
    (set-frame-parameter
     nil 'fullscreen
     (when (not (frame-parameter nil 'fullscreen)) 'fullboth))))

(global-set-key [f11] 'toggle-fullscreen)

;; Annoyingly minimizes the frame
(global-unset-key (kbd "C-z"))

(global-set-key (kbd "C-<tab>") 'completion-at-point)

(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; y instead of yes
(defalias 'yes-or-no-p 'y-or-n-p)

(defun coffee-custom ()
  "coffee-mode-hook"
  (setq coffee-tab-width 2)
  (local-set-key (kbd "TAB") 'coffee-indent-shift-right)
  (local-set-key (kbd "S-TAB") 'coffee-indent-shift-left))

(add-hook 'coffee-mode-hook 'coffee-custom 'projectile-mode)
(add-to-list 'auto-mode-alist '("\\.cjsx\\'" . coffee-mode))

;; File watchers tend to choke on emacs tmp files


(setq
   backup-by-copying t      ; don't clobber symlinks
   backup-directory-alist
    '(("." . "~/.saves"))    ; don't litter my fs tree
   delete-old-versions t
   kept-new-versions 6
   kept-old-versions 2
   version-control t)       ; use versioned backups

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))

(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(setq js-indent-level 2)

(require 'magit)
(setq magit-last-seen-setup-instructions "1.4.0")
(setq git-commit-finish-query-functions nil)

(put 'erase-buffer 'disabled nil)

(define-globalized-minor-mode
  global-text-scale-mode
  text-scale-mode
  (lambda () (text-scale-mode 1)))

(defun global-text-scale-adjust (inc) (interactive)
       (text-scale-set 1)
       (kill-local-variable 'text-scale-mode-amount)
       (setq-default text-scale-mode-amount (+ text-scale-mode-amount inc))
       (global-text-scale-mode 1))

(global-set-key (kbd "M-0")
                '(lambda () (interactive)
                   (global-text-scale-adjust (- text-scale-mode-amount))
                   (global-text-scale-mode -1)))
(global-set-key (kbd "M-+")
                '(lambda () (interactive) (global-text-scale-adjust 1)))
(global-set-key (kbd "M-=")
                '(lambda () (interactive) (global-text-scale-adjust 1)))
(global-set-key (kbd "M--")
                '(lambda () (interactive) (global-text-scale-adjust -1)))

(setq sql-postgres-login-params
      '((user :default "postgres")
        (database :default "allovue_development")
        (server :default "localhost")
        (port :default 5432)))

(add-hook 'sql-interactive-mode-hook
          (lambda ()
            (toggle-truncate-lines t)))

(global-set-key (kbd "C-S-<left>") (lambda ()
                                     (interactive)
                                     (shrink-window-horizontally 8)))
(global-set-key (kbd "C-S-<right>") (lambda ()
                                      (interactive)
                                      (enlarge-window-horizontally 8)))
(global-set-key (kbd "C-S-<down>") (lambda ()
                                     (interactive)
                                     (shrink-window 4)))


(global-set-key (kbd "C-S-<up>") (lambda ()
                                   (interactive)
                                   (enlarge-window 4)))

(global-set-key (kbd "C-S-j") (lambda ()
                                (interactive)
                                (shrink-window-horizontally 8)))
(global-set-key (kbd "C-:") (lambda ()
                              (interactive)
                              (enlarge-window-horizontally 8)))
(global-set-key (kbd "C-S-k") (lambda ()
                                (interactive)
                                (shrink-window 4)))
(global-set-key (kbd "C-S-l") (lambda ()
                                (interactive)
                                (enlarge-window 4)))

;; ## added by OPAM user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
(require 'opam-user-setup "~/.emacs.d/opam-user-setup.el")
;; ## end of OPAM user-setup addition for emacs / base ## keep this line
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(define-key merlin-mode-map (kbd "M-,") 'merlin-pop-stack)
(add-hook 'projectile-after-switch-project-hook 'direnv-update-environment)

(define-key merlin-mode-map (kbd "M-.") 'merlin-locate)
;;; opens up an interface when present
(setq merlin-locate-preference 'mli)

;;; better-defaults assumes we want helm, but it's a little annoying for the quick file open 
(global-set-key (kbd "C-x C-f") 'ido-find-file)
(setq ido-enable-flex-matching t)
