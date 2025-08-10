#lang sicp
;; file: 4_07.rkt
;; 4_06 cont

(#%require rackunit)
(#%require (prefix racket/ racket))
(#%require "../allcode/ch4-4.1.1-mceval.rkt")

;; 1-1. let*식이 여러개의 let식으로 변환될 수 있는지.
;;
;;  (let* ((x 3)
;;         (y (+ x 2))
;;         (z (+ x y 5)))
;;    (* x z)))
;;
;; (let ((x 3))
;;   (let ((y (+ x 2)))
;;     (let ((z (+ x y 5)))
;;       (* x z)))))
;;
;; 1-2. let*->nested-lets 를 작성해라.

(define first car)
(define rest cdr)
(define second cadr)
(define third caddr)

(define (make-let binding body)
    (if (null? binding)
        (append (list 'let '()) body)
        (append (list 'let (list binding)) body)))

(check-equal? (make-let '(b 1) (list (make-let '((a 1)) '((display) (display)))))
              '(let ((b 1)) (let (((a 1))) (display) (display))))

(check-equal? (make-let '(b 1) '('a 'b))
              '(let ((b 1)) 'a 'b))


(define (let*->nested-lets expr)
  (define (iter acc bs)
    (if (null? bs)
        acc
        (iter (make-let (first bs) (list acc)) (rest bs))))
  (let* ((bindings (reverse (second expr)))
         (body (rest (rest expr))))
    (if (null? bindings)
        (make-let '() body)
        (iter (make-let (first bindings) body) (rest bindings)))))

(define (let*? expr)
  (tagged-list? expr 'let*))

(check-equal? (let*->nested-lets
               '(let* ((x 3)
                       (y (+ x 2))
                       (z (+ x y 5)))
                  (* x z)))   
              '(let ((x 3))
                 (let ((y (+ x 2)))
                   (let ((z (+ x y 5)))
                     (* x z)))))

(check-equal? (let*->nested-lets
               '(let* () 1))
              '(let () 1))

(check-equal? (let*->nested-lets
               '(let* ((x 3)
                       (y x))
                  'a
                  'b))
              '(let ((x 3))
                 (let ((y x))
                   'a
                   'b)))

;; 2.1 eval에 (eval (let*->nested-lets exp) env)를 추가하면 동작할까?
;; 동작 한다.


(#%require "4_06.rkt")

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
        ((let*? exp) (eval (let*->nested-lets exp) env)) ; <<--- 이번 4_07에서 추가.
        
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unknown expression type -- EVAL" exp))))
(override-eval! eval)

(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(define-variable! '* (list 'primitive *) env2)

(#%require (prefix  r5rs/ r5rs))
(define expression '(let* ((x 3)
                           (y (+ x 2))
                           (z (+ x y 5)))
                      (* x z)))

(#%require (prefix trace/ racket/trace))

(check-equal? (eval expression env2)
              (r5rs/eval expression (scheme-report-environment 5)))

