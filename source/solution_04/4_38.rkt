#lang sicp
;; file: 4_38.rkt
;; 4_38, 4_39, 4_40

(#%require rackunit)
(#%require threading)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; multiple-dwelling에서 Smith와 Fletcher가 인접층에 살지 않는다는 require를 빼도록 수정해라. 얼마나 많은 솔루션이 있는가?

(define env3 (setup-environment))
(~> '(define (require p)
       (if (not p)
           (amb)))
    (run env3)
    (check-equal? 'ok))

(~> '(define (distinct? items)
       (cond ((null? items) true)
             ((null? (cdr items)) true)
             ((member (car items) (cdr items)) false)
             (else (distinct? (cdr items)))))
    (run env3)
    (check-equal? 'ok))

(~> '(define (multiple-dwelling)
       (let ((baker (amb 1 2 3 4 5))
             (cooper (amb 1 2 3 4 5))
             (fletcher (amb 1 2 3 4 5))
             (miller (amb 1 2 3 4 5))
             (smith (amb 1 2 3 4 5)))
         (require
           (distinct? (list baker cooper fletcher miller smith)))
         (require (not (= baker 5)))
         (require (not (= cooper 1)))
         (require (not (= fletcher 5)))
         (require (not (= fletcher 1)))
         (require (> miller cooper))
         ;; Smith와 Fletcher가 인접층에 살지 않는다는 require를 빼도록 수정해라.
         ;; (require
         ;;   (not (= (abs (- smith fletcher)) 1)))
         (require 
           (not (= (abs (- fletcher cooper)) 1)))
         (list (list 'baker baker)
               (list 'cooper cooper)
               (list 'fletcher fletcher)
               (list 'miller miller)
               (list 'smith smith))))
    (run env3)
    (check-equal? 'ok))

(~> '(multiple-dwelling)
    (runs env3)
    (length)
    (check-equal? 5))