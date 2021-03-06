(setq mac-option-modifier 'alt)
(setq mac-command-modifier 'meta)
;; open bookmark
(global-set-key [f2] 'bookmark-bmenu-list)
(global-set-key [home] 'beginning-of-line)
(global-set-key [end] 'end-of-line)
(global-set-key [f4] '(lambda () (interactive) (kill-buffer (current-buffer))))
(global-set-key [f3] '(lambda () (interactive) (save-buffer) (kill-buffer (current-buffer))))
                                        ;(define-key hah-key-map [C-home] 'beginning-of-buffer)
                                        ;(define-key hah-key-map [C-end] 'end-of-buffer)
                                        ;(Global-set-key (kbd "C-x g") (lambda() (interactive) (magit-status "/Users/dhu/work/webapp")))
(global-set-key [f12] (lambda() (interactive) (magit-status "/Users/dhu/work/webapp")))


;;smart copy, if no region active, it simply copy the current whole line
(defadvice kill-line (before check-position activate)
  (if (member major-mode
              '(emacs-lisp-mode scheme-mode lisp-mode
                                c-mode c++-mode objc-mode js-mode
                                latex-mode plain-tex-mode))
      (if (and (eolp) (not (bolp)))
          (progn (forward-char 1)
                 (just-one-space 0)
                 (backward-char 1)))))

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive (if mark-active (list (region-beginning) (region-end))
                 (message "Copied line")
                 (list (line-beginning-position)
                       (line-beginning-position 2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

;; Copy line from point to the end, exclude the line break
(defun qiang-copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  (interactive "p")
  (kill-ring-save (point)
                  (line-end-position))
  ;; (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

(global-set-key (kbd "M-k") 'qiang-copy-line)
(defun qiang-comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
If no region is selected and current line is not blank and we are not at the end of the line,
then comment current line.
Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
(global-set-key "\M-;" 'qiang-comment-dwim-line)
;;(setq line-number-mode t)

;;
(global-set-key "\M-'" 'ace-jump-mode) ;

;;increate font size
(defun increase-font-size()
  "increase font size"
  (interactive)
  (if (< cjk-font-size 48)
      (progn
        (setq cjk-font-size (+ cjk-font-size 2))
        (setq ansi-font-size (+ ansi-font-size 2))))
  (message "cjk-size:%d pt, ansi-size:%d pt" cjk-font-size ansi-font-size)
  (set-font) 
  (sit-for .5))

;; 函数字体增大，每次减小2个字号，最小2号
(defun decrease-font-size()
  "decrease font size"
  (interactive)
  (if (> cjk-font-size 2)
      (progn
        (setq cjk-font-size (- cjk-font-size 2))
        (setq ansi-font-size (- ansi-font-size 2))))
  (message "cjk-size:%d pt, ansi-size:%d pt" cjk-font-size ansi-font-size)
  (set-font)
  (sit-for .5))

;; 恢复成默认大小16号
(defun default-font-size()
  "default font size"
  (interactive)
  (setq cjk-font-size 16)
  (setq ansi-font-size 16)
  (message "cjk-size:%d pt, ansi-size:%d pt" cjk-font-size ansi-font-size)
  (set-font)
  (sit-for .5))


(add-hook 'ruby-mode-hook 'projectile-mode)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq org-plantuml-jar-path
      (expand-file-name "/opt/plantuml.jar"))
(setq plantuml-jar-path "/opt/plantuml.jar")
;; active Org-babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '(;; other Babel languages
   (plantuml . t)))

(global-linum-mode t)
;;
;;(defun open-pic ()
;;  (shell-command-to-string) "java -jar ~/plantuml.jar "c
                                        ;)

(add-hook 'after-init-hook 'auto-complete-mode)
(setq ac-dwim t)
(ac-config-default)
(require 'smart-tab)
(global-smart-tab-mode 1)
(setq ac-auto-start 2)
(setq ac-fuzzy-enable t)
(windmove-default-keybindings)
;;(global-git-gutter+-mode t)
(require 'git-gutter-fringe+)

;;;Add middle minibuffer
;;;
;;;

(defun my-dynamic-position ()
  (/ (frame-pixel-height) 2)
  )
                                        ;(my-dynamic-position)

;;(require 'oneonone)
;;(1on1-emacs)
;;(1on1-set-minibuffer-frame-top/bottom nil)
                                        ;(defadvice 1on1-set-minibuffer-frame-top/bottom (around center activate)
                                        ; (let ((1on1-minibuffer-frame-top/bottom  (my-dynamic-position)))
                                        ;  ad-do-it))


(defun run-remote-pry (&rest args)
  (interactive)
  (let ((buffer (apply 'make-comint "pry-remote" "pry-remote" nil args)))
    (switch-to-buffer buffer)
    (setq-local comint-process-echoes t)))
(defun my-screenshot ()
  "Take a screenshot into a unique-named file in the current buffer file
 directory and insert a link to this file."
  (interactive)
  (setq filename
        (concat (make-temp-name
                 (concat (file-name-directory (buffer-file-name)) "images/" ) ) ".png"))
  (if (file-accessible-directory-p (concat (file-name-directory (buffer-file-name)) "images/"))
      nil
    (make-directory "images"))
  (call-process "screencapture" nil nil nil "-s" filename)

  (insert (concat "[["  filename "]]"))
  (org-display-inline-images)
  )
(require 'evil)
(evil-mode 1)
;; AceJump integration is now included in evil, this gist is only preserved for historical reasons.
;; Please use the provided integration (it's far more advanced)

;; AceJump is a nice addition to evil's standard motions.

;; The following definitions are necessary to define evil motions for ace-jump-mode (version 2).

;; ace-jump is actually a series of commands which makes handling by evil
;; difficult (and with some other things as well), using this macro we let it
;; appear as one.

(defmacro evil-enclose-ace-jump (&rest body)
  `(let ((old-mark (mark))
         (ace-jump-mode-scope 'window))
     (remove-hook 'pre-command-hook #'evil-visual-pre-command t)
     (remove-hook 'post-command-hook #'evil-visual-post-command t)
     (unwind-protect
         (progn
           ,@body
           (recursive-edit))
       (if (evil-visual-state-p)
           (progn
             (add-hook 'pre-command-hook #'evil-visual-pre-command nil t)
             (add-hook 'post-command-hook #'evil-visual-post-command nil t)
             (set-mark old-mark))
         (push-mark old-mark)))))

(evil-define-motion evil-ace-jump-char-mode (count)
  :type exclusive
  (evil-enclose-ace-jump
   (ace-jump-mode 5)))

(evil-define-motion evil-ace-jump-line-mode (count)
  :type line
  (evil-enclose-ace-jump
   (ace-jump-mode 9)))

(evil-define-motion evil-ace-jump-word-mode (count)
  :type exclusive
  (evil-enclose-ace-jump
   (ace-jump-mode 1)))

(evil-define-motion evil-ace-jump-char-to-mode (count)
  :type exclusive
  (evil-enclose-ace-jump
   (ace-jump-mode 5)
   (forward-char -1)))

(add-hook 'ace-jump-mode-end-hook 'exit-recursive-edit)

;; some proposals for binding:

(define-key evil-motion-state-map (kbd "SPC") #'evil-ace-jump-char-mode)
(define-key evil-motion-state-map (kbd "C-SPC") #'evil-ace-jump-word-mode)

(define-key evil-operator-state-map (kbd "SPC") #'evil-ace-jump-char-mode)      ; similar to f
(define-key evil-operator-state-map (kbd "C-SPC") #'evil-ace-jump-char-to-mode) ; similar to t
(define-key evil-operator-state-map (kbd "M-SPC") #'evil-ace-jump-word-mode)

;; different jumps for different visual modes
(defadvice evil-visual-line (before spc-for-line-jump activate)
  (define-key evil-motion-state-map (kbd "SPC") #'evil-ace-jump-line-mode))

(defadvice evil-visual-char (before spc-for-char-jump activate)
  (define-key evil-motion-state-map (kbd "SPC") #'evil-ace-jump-char-mode))

(defadvice evil-visual-block (before spc-for-char-jump activate)
  (define-key evil-motion-state-map (kbd "SPC") #'evil-ace-jump-char-mode))
(cua-mode t)
(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(transient-mark-mode 1) ;; No region when it is not highlighted
(setq cua-keep-region-after-copy t) ;; Standard Windows behaviour
(eval-after-load "org"
  '(require 'ox-md nil t))
(defun my-add-date ()
  (rename-file (buffer-file-name) (current-file) ))
(defun my-add-date ()
  (interactive)
  (let* ((file (buffer-file-name))
         (dir  (file-name-directory file))
         (filename (file-name-nondirectory file))
         (date (format-time-string "%Y-%m-%d"))
         (newName (concat dir date "-" filename )))
    (progn
      (rename-file file newName 1)
      (rename-buffer newName)
      (set-visited-file-name newName)
      (set-buffer-modified-p nil))))


(current-buffer)
(buffer-file-name)
(find-file (buffer-file-name))
(file-name-nondirectory (buffer-file-name))
(file-name-directory (buffer-file-name))
(set-face-attribute 'org-level-1 nil :height 1.6 :bold t)
(set-face-attribute 'org-level-2 nil :height 1.4 :bold t)
(set-face-attribute 'org-level-3 nil :height 1.2 :bold t)

;; active Org-babel languages
(setq org-startup-indented t)
(setq org-startup-folded "showall")
(global-set-key [M-c] 'cua-copy-region)
(global-set-key [M-v] 'cua-paste)
(provide 'init-local)
