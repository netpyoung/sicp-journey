#lang sicp
;; file: 4_09.rkt
;; 4_06 4_07 cont

(#%require rackunit)
(#%require "../helper/my-util.rkt")
(#%require threading)
(#%require (prefix racket: racket))
(#%require (prefix r5rs/ r5rs))
(racket:provide
 do?
 while?
 until?
 do->expand
 while->do
 until->do)


;;  do / for / while / until 를 derived expression으로 구현해라
;; ref:
;; guile - do - https://www.gnu.org/software/guile/manual/html_node/while-do.html
;; common lisp - do - https://www.lispworks.com/documentation/HyperSpec/Body/m_do_do.htm
;; ruby - do for while until - https://www.geeksforgeeks.org/ruby/ruby-loops-for-while-do-while-until/

;; Derived expressions.
;; 4.1.2Representing Expressions
;;  - Derived expressions
;; (cond ((> x 0) x)
;;       ((= x 0) (display 'zero) 0)
;;       (else (- x)))
;;
;; (if (> x 0)
;;     x
;;     (if (= x 0)
;;         (begin (display 'zero) 0)
;;         (- x)))
;;
;; - cond는 if로 변환하여 계산됨
;;   -cond는 if로부터 파생된(derived) 표현식임)
(define (second-or-nil expr)
  (let ((x  (rest expr)))
    (if (null? x)
        nil
        (first x))))
(define (third-or-nil expr)
  (let ((x (rest (rest expr))))
    (if (null? x)
        nil
        (first x))))

(define (make-define func-name args body)
  (append (list 'define (append (list func-name) args)) body))
(define (filter predicate sequence)
  (cond ((null? sequence) nil)
        ((predicate (car sequence))
         (cons (car sequence)
               (filter predicate (cdr sequence))))
        (else (filter predicate (cdr sequence)))))

(define (comp f g h)
  (lambda (x)
    (h (f (g x)))))

(define (make-do vars assigns step-or-nils test ret body)
  (list 'let* (map list vars assigns)
        (make-define 'loop '()
                     (list (list 'if test
                                 ret
                                 (append (list 'begin)
                                         body
                                         (~>> (map (lambda (v x) (if (null? x) nil (list 'set! v x))) vars step-or-nils)
                                              (filter (comp not null? identity) ))
                                         '((loop))))))
        '(loop)))

(define (do->expand expr)
  (let* ((snd (second expr))
         (trd (third expr))
         (vars (map first snd))
         (assigns (map second snd))
         (step-or-nils (map third-or-nil snd))
         (test (first trd))
         (ret (second-or-nil trd))
         (body (rest (rest (rest expr)))))
    (make-do vars assigns step-or-nils test ret body)))

(check-equal? (do ((i 10 (dec i))
                   (j '()))
                ((< i 0) j)
                (set! j (cons i j)))
              '(0 1 2 3 4 5 6 7 8 9 10))

(check-equal? (do->expand '(do ((i 10 (dec i))
                                (j '()))
                             ((< i 0) j)
                             (set! j (cons i j))))
              
              '(let* ((i 10)
                      (j '()))
                 (define (loop)
                   (if (< i 0)
                       j
                       (begin
                         (set! j (cons i j))
                         (set! i (dec i))
                         (loop))))
                 (loop)))



(define (while->do expr)
  (let ((vars '())
        (assigns '())
        (step-or-nils '())
        (test (second expr))
        (ret (quote '()))
        (body (rest (rest expr))))
    (make-do vars assigns step-or-nils (list 'not test) ret body)))

(check-equal? (while->do '(while (> i 0)
                                 (set! i (dec i))))
              '(let* ()
                 (define (loop)
                   (if (not (> i 0))
                       '()
                       (begin
                         (set! i (dec i))
                         (loop))))
                 (loop)))

(define (until->do expr)
  (let ((vars '())
        (assigns '())
        (step-or-nils '())
        (test (second expr))
        (ret (quote '()))
        (body (rest (rest expr))))
    (make-do vars assigns step-or-nils test ret body)))

(check-equal? (until->do '(until (> i 5)
                                 (set! i (inc i))))
              '(let* ()
                 (define (loop)
                   (if (> i 5)
                       '()
                       (begin
                         (set! i (inc i))
                         (loop))))
                 (loop)))

;; eval이 let구문을 처리할 수 있도록 수정 ---------------
(#%require (all-except "../allcode/ch4-4.1.1-mceval.rkt" eval))
(#%require "4_06.rkt")
(#%require "4_07.rkt")

(define (do? exp) (tagged-list? exp 'do))
(define (while? exp) (tagged-list? exp 'while))
(define (until? exp) (tagged-list? exp 'until))

(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
        ((quoted? exp) (text-of-quotation exp))
        ((assignment? exp) (eval-assignment exp env))
        ((definition? exp) (eval-definition exp env))
        ((if? exp) (eval-if exp env))
        ((lambda? exp)
         (make-procedure (lambda-parameters exp)
                         (lambda-body exp)
                         env))
        ((begin? exp) 
         (eval-sequence (begin-actions exp) env))
        ((cond? exp) (eval (cond->if exp) env))
        ((let? exp) (eval (let->combination exp) env))   ; <<--- 저번 4_06에서 추가.
        ((let*? exp) (eval (let*->nested-lets exp) env)) ; <<--- 저번 4_07에서 추가.
        ((do? exp) (eval (do->expand exp) env)) ;; <<--- 추가.
        ((while? exp) (eval (while->do exp) env))
        ((until? exp) (eval (until->do exp) env))
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unknown expression type -- EVAL" exp))))
(override-eval! eval)

(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(define-variable! '- (list 'primitive -) env2)
(define-variable! '= (list 'primitive =) env2)
(define-variable! '< (list 'primitive <) env2)
(define-variable! '> (list 'primitive >) env2)
(define-variable! 'inc (list 'primitive inc) env2)
(define-variable! 'dec (list 'primitive dec) env2)
(define-variable! 'not (list 'primitive not) env2)


(check-equal? (eval '(do ((i 10 (dec i))
                          (j '()))
                       ((< i 0) j)
                       (set! j (cons i j)))
                    env2)
              '(0 1 2 3 4 5 6 7 8 9 10))

(check-equal? (eval '(let ((acc '())
                           (i 5))
                       (while (> i 0)
                              (set! acc (cons i acc))
                              (set! i (dec i)))
                       acc)
                    env2)
              '(1 2 3 4 5))

(check-equal? (eval '(let ((acc '())
                           (i 1))
                       (until (> i 5)
                              (set! acc (cons i acc))
                              (set! i (inc i)))
                       acc)
                    env2)
              '(5 4 3 2 1))