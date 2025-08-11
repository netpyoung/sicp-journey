#lang sicp
;; file: 4_06.rkt
;; 4_07 / 4_08


(#%require (prefix racket/ racket))
(#%require rackunit)
(racket/provide
 let?
 let->combination)

(define first car)
(define rest cdr)
(define second cadr)
(define third caddr)

;; let->combination 구현 ------------------------------
;; 중첩 let을 생각안하면 4_07에서 오류를 맞이할거임.

(define (let->combination let-clause)
  (let* ((bindings (second let-clause))
         (vars (map first bindings))
         (exps (map second bindings))
         (body (rest (rest let-clause))))
    (cons (make-lambda vars body)
          exps)))

(check-equal? (let->combination '(let ((a 1) (b 2)) (+ a b)))
              '((lambda (a b) (+ a b)) 1 2))

(check-equal? (let->combination '(let () 1))
              '((lambda () 1))
              "empty")


;; eval이 let구문을 처리할 수 있도록 수정 ---------------
(#%require "../allcode/ch4-4.1.1-mceval.rkt")

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
        ((let? exp) (eval (let->combination exp) env)) ;; <<--- 추가.
        ((application? exp)
         (apply (eval (operator exp) env)
                (list-of-values (operands exp) env)))
        (else
         (error "Unknown expression type -- EVAL" exp))))
(override-eval! eval)
(define (let? exp) (tagged-list? exp 'let))


;; test -----------------------

(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(check-equal? (eval '(let ((a 1) (b 2)) (+ a b)) env2) 3)