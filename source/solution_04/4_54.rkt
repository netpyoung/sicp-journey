#lang sicp
;; file: 4_54.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; amb함수를 써서 require 함수를 구현하는 방법을 모른다면, special form으로 만들어야함.
;; special form으로 require문을 처리해라.

(define (require? exp) 
  (tagged-list? exp 'require))

(define (require-predicate exp) 
  (cadr exp))

(define (analyze-require exp)
  ;; analyze-if 참고.
  (let ((pproc (analyze (require-predicate exp))))
    (lambda (env succeed fail)
      (pproc env
             (lambda (pred-value fail2)
               (if (not pred-value)
                   (fail2)
                   (succeed 'ok fail2)))
             fail))))

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
        ((let? exp) (analyze (let->combination exp)))
        ((amb? exp) (analyze-amb exp))
        ((require? exp) (analyze-require exp))   ; <-----------------
        ((application? exp) (analyze-application exp))
        (else
         (error "Unknown expression type -- ANALYZE" exp))))

(override-analyze! analyze)

;; =================================================


(define env2 (setup-environment))
(~> '(let ((x (amb 0 1 2)))
       (require (> x 0))
       x)
    (runs env2)
    (check-equal? '(1 2)))

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
         (= n (smallest-divisor n)))

       (define (an-element-of items)
         (require (not (null? items)))
         (amb (car items) 
              (an-element-of (cdr items))))
       
       (define (prime-sum-pair list1 list2)
         (let ((a (an-element-of list1))
               (b (an-element-of list2)))
           (require (prime? (+ a b)))
           (list a b)))
       )
    (run env2)
    (check-equal? 'ok))


(~> '(prime-sum-pair '(1 3 5 8) '(20 35 110))
    (runs env2)
    (check-equal? '((3 20)
                    (3 110)
                    (8 35))))
(~> '(prime-sum-pair '(19 27 30) '(11 36 58))
    (run env2)
    (check-equal? '(30 11)))