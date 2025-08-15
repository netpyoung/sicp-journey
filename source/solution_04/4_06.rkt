#lang sicp
;; file: 4_06.rkt
;; 4_07 / 4_08 / 4_09 / 4_16 / 4_17 / 4_18
;; 4_22


(#%require rackunit)
(#%require "../helper/my-util.rkt")
(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.1.1-mceval.rkt" (_eval origin/eval)))

(racket:provide
 let?
 let->combination)


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

(override-eval! origin/eval)
