#lang sicp
;; file: 4_28.rkt
(#%require rackunit)
(#%require threading)
(#%require (prefix racket: racket))
(racket:require "../allcode/ch4-4.2.2-leval.rkt")

;; Q. 예전에는 operator를 apply 에 넘겨주게 전에 그냥 eval했는데 왜 이젠 actual-value를 쓰는가?
;;
;; ch4-4.2.2-leval 에서는 apply시 operator에 actual-value적용
;; 
;; actual-value는 eval + force-it임.
;; 그럼 operator에 왜 추가적으로 force-it을 하는가. operator로 thunk가 올 수 있기 때문.

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
        ((application? exp)
         ;;  기존 leval코드는  operator에 actual-value적용.
         ;; (apply (actual-value (operator exp) env)
         ;;          (operands exp)
         ;;          env)

         (apply (eval (operator exp) env)
                (operands exp)
                env))
        (else
         (error "Unknown expression type -- EVAL" exp))))


(override-eval! eval)
(define env1 (setup-environment))

(~> '(define (id x) x)
    (actual-value env1)
    (check-eq? 'ok))

(~> '(define op (id +))
    (actual-value env1)
    (check-eq? 'ok))

(~> 'op
    (lookup-variable-value env1)
    (thunk?)
    (check-true))

(check-exn #rx"Unknown procedure type"
           (lambda ()
             (~> '(op 1 2)
                 (actual-value env1))))
