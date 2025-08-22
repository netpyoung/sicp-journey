#lang sicp
;; file: 4_53.rkt
;; 4_51 / 4_52 / 4_53

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; 연습문제 4.51의 permanent-set! 와 연습문제 4.52의 if-fail을 가지고 다음을 구해보면?

;; 일단 permanent-set! / if-fail 적용시켜주고,
(#%require "4_51.rkt")
(#%require "4_52.rkt")

(define (analyze exp)
  (cond ((self-evaluating? exp) 
         (analyze-self-evaluating exp))
        ((quoted? exp) (analyze-quoted exp))
        ((variable? exp) (analyze-variable exp))
        ((assignment? exp) (analyze-assignment exp))
        ((permutation-set? exp) (analyze-permutation-set exp))   ;**
        ((definition? exp) (analyze-definition exp))
        ((if? exp) (analyze-if exp))
        ((if-fail? exp) (analyze-if-fail exp))   ;**
        ((lambda? exp) (analyze-lambda exp))
        ((begin? exp) (analyze-sequence (begin-actions exp)))
        ((cond? exp) (analyze (cond->if exp)))
        ((let? exp) (analyze (let->combination exp)))
        ((amb? exp) (analyze-amb exp))
        ((application? exp) (analyze-application exp))
        (else
         (error "Unknown expression type -- ANALYZE" exp))))

(override-analyze! analyze)

;; =================================================

(define env3 (setup-environment))
(define-variable! 'even? (list 'primitive even?) env3)
(~> '(begin
       (define (square x) (* x x))
       
       (define (smallest-divisor n)
         (find-divisor n 2))

       (define (find-divisor n test-divisor)
         (cond ((> (square test-divisor) n) n)
               ((divides? test-divisor n) test-divisor)
               (else (find-divisor n (+ test-divisor 1)))))

       (define (divides? a b)
         (= (remainder b a) 0))

       (define (prime? n)
         (= n (smallest-divisor n))))
    (run env3)
    (check-equal? 'ok))

(~> '(begin
       (define (require p)
         (if (not p)
             (amb)))

       (define (an-element-of items)
         (require (not (null? items)))
         (amb (car items) (an-element-of (cdr items))))
       
       (define (prime-sum-pair list1 list2)
         (let ((a (an-element-of list1))
               (b (an-element-of list2)))
           (require (prime? (+ a b)))
           (list a b)))
       )
    (run env3)
    (check-equal? 'ok))

(~> '(let ((pairs '()))
       (if-fail (let ((p (prime-sum-pair 
                          '(1 3 5 8) 
                          '(20 35 110))))
                  (permanent-set! pairs (cons p pairs))
                  (amb))
                pairs))
    (runs env3)
    (check-equal? '(
                    ((8 35) (3 110) (3 20))
                    ))
    )