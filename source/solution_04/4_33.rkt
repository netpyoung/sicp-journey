#lang sicp
;; file: 4_33.rkt
(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require "../allcode/helper/my-util.rkt")

(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.2.2-leval.rkt"
                                  (_eval-sequence lazy:eval-sequence)))
;; leval에서 '(car '(a b c))를 처리할 수 없는데 처리할 수 있도록 고쳐라.

;;
;; before
;; car의 정의에 따라 풀면 ('(a b c) (lambda (p q) p)) 이런식이 되는데, 이러면 당연히 에러가 날 것이다.
;;
(define env1 (setup-environment))
(~> '(begin
       (define (cons x y)
         (lambda (m)
           (m x y)))
       (define (car z)
         (z
          (lambda (p q) p)))
       (define (cdr z)
         (z
          (lambda (p q) q))))
    (actual-value env1)
    (check-equal? 'ok))
(check-exn
 #rx"Unknown procedure type -- APPLY \\(a b c\\)"
 (lambda ()
   (~>'(car '(a b c))
      (actual-value env1))))

;;
;; after
;; '(a b c)를 lazy list로 풀면 (cons (quote a) (cons (quote b) (cons (quote c) nil))) 잘 동작할 것이다.
;;

(define (handle-quoted expr)
  (define (quoted-list lst)
    ;; (quoted-list '(a b c))
    ;;=> (cons (quote a) (cons (quote b) (cons (quote c) ())))
    (define (iter acc xs)
      (if (null? xs)
          acc
          (iter (list 'cons (list 'quote (first xs)) acc) (rest xs))))
    (iter '() (reverse lst)))
  (define (quoted-cons pair)
    ;; (quoted-cons '(a . b)
    ;;=> '(cons (quote a) (quote b)))
    (list 'cons
          (list 'quote (first pair))
          (list 'quote (rest pair))))
  (cond ((list? expr)
         (quoted-list expr))
        ((pair? expr)
         (quoted-cons expr))
        (else
         expr)))

(check-equal? (handle-quoted '(a . b))
              '(cons (quote a) (quote b)))
(check-equal? (handle-quoted '(a b c))
              '(cons (quote a) (cons (quote b) (cons (quote c) ()))))
(check-equal? (handle-quoted 'a)
              'a)

(define (eval-quoted expr env)
  (let ((q (handle-quoted expr)))
    (if (pair? q)
        (eval q env)
        q)))

(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
        ((quoted? exp)
         (eval-quoted (text-of-quotation exp) env))
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
        ((application? exp)             ; clause from book
         (apply (actual-value (operator exp) env)
                (operands exp)
                env))
        (else
         (error "Unknown expression type -- EVAL" exp))))

(override-eval! eval)
(define env2 (setup-environment))
(~> '(begin
       (define (cons x y)
         (lambda (m)
           (m x y)))
       (define (car z)
         (z
          (lambda (p q) p)))
       (define (cdr z)
         (z
          (lambda (p q) q))))
    (actual-value env2)
    (check-equal? 'ok))
(~>'(car '(a b c))
   (actual-value env2)
   (check-equal? 'a))
