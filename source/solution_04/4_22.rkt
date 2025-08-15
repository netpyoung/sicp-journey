#lang sicp
;; file: 4_22.rkt
(#%require (prefix racket/ racket))
(#%require rackunit)
(racket/require "4_06.rkt")
(racket/require (racket/except-in "../allcode/ch4-4.1.1-mceval.rkt" eval))
(racket/require (racket/rename-in "../allcode/ch4-4.1.7-analyzingmceval.rkt" (_analyze origin/analyze)))

(racket/provide
 analyze-let
 )
;; 4_06 참고. let을 처리 할 수 있도록 확장.

(define (analyze-let exp)
  (analyze (let->combination exp)))

(define (analyze exp)
  (cond ((self-evaluating? exp) 
         (analyze-self-evaluating exp))
        ((quoted? exp) (analyze-quoted exp))
        ((variable? exp) (analyze-variable exp))
        ((assignment? exp) (analyze-assignment exp))
        ((definition? exp) (analyze-definition exp))
        ((if? exp) (analyze-if exp))
        ((lambda? exp) (analyze-lambda exp))
        ((begin? exp) (analyze-sequence (begin-actions exp)))
        ((cond? exp) (analyze (cond->if exp)))
        ((let? exp) (analyze-let exp)) ;; <----- 4_22 추가됨.
        ((application? exp) (analyze-application exp))
        (else
         (error "Unknown expression type -- ANALYZE" exp))))

(override-analyze! analyze)

(define env2 (setup-environment))
(define-variable! '+ (list 'primitive +) env2)
(check-equal? ((analyze '(let ((a 1) (b 2)) (+ a b))) env2)
              3)

(override-analyze! origin/analyze)
