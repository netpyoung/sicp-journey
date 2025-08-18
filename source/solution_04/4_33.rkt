#lang sicp
;; file: 4_33.rkt
(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require "../allcode/helper/my-util.rkt")

(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.2.2-leval.rkt"
                                  (_eval-sequence lazy:eval-sequence)))

;; TODO

(override-force-it! force-it-memoizing)
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
 #rx"Unknown procedure type"
 (lambda ()
   (~>'(car '(a b c))
      (actual-value env1))))