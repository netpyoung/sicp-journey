#lang sicp
;; file: 4_52.rkt
;; 4_51 / 4_52 / 4_53
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(racket:provide
 ;;  ((if-fail? exp) (analyze-if-fail exp))   ;**
 if-fail? analyze-if-fail)

;; 표현식 2개를 받아 첫번째가 성공시 첫번째 값을, 실패시 두번째 값을 반환하는 if-fail을 구현해라.


(define (if-fail? exp)
  (tagged-list? exp 'if-fail))

(define (analyze-if-fail exp)
  (let ((pproc (analyze (if-predicate exp)))
        (cproc (analyze (if-consequent exp))))
    (lambda (env succeed fail)
      ;; before: analyze-if
      ;; (pproc env
      ;;        (lambda (pred-value fail2)
      ;;          (if (true? pred-value)
      ;;              (cproc env succeed fail2)
      ;;              (aproc env succeed fail2)))
      ;;        fail)
      ;;
      ;; after: analyze-if-fail
      (pproc env
             succeed
             (lambda ()
               (cproc env succeed fail))))))

(define (analyze exp)
  (cond ((self-evaluating? exp) 
         (analyze-self-evaluating exp))
        ((quoted? exp) (analyze-quoted exp))
        ((variable? exp) (analyze-variable exp))
        ((assignment? exp) (analyze-assignment exp))
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

;; ======================================

(define env3 (setup-environment))
(define-variable! 'even? (list 'primitive even?) env3)
(~> '(begin
       (define (require p)
         (if (not p)
             (amb)))
       (define (an-element-of items)
         (require (not (null? items)))
         (amb (car items) (an-element-of (cdr items))))
       )
    (run env3)
    (check-equal? 'ok))

(~> '(if-fail 
      (let ((x (an-element-of '(1 3 5))))
        (require (even? x))
        x)
      'all-odd)
    (run env3)
    (check-equal? 'all-odd)
    )

(~> '(if-fail 
      (let ((x (an-element-of '(1 3 5 8))))
        (require (even? x))
        x)
      'all-odd)
    (run env3)
    (check-equal? '8)
    )