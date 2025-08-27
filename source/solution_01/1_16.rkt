#lang sicp
;; file: 1_16.rkt
;; 1_16 / 1_17 / 1_18
(#%require threading)
(#%require rackunit)
(#%require profile)

;; fast-expt를 iterate하게 바꿔라


(define (square x)
  (* x x))

(define (fast-expt b n)
  (cond (( = n 0)
         1)
        ((even? n)
         (square (fast-expt b (/ n 2))))
        (else
         (* b (fast-expt b (- n 1))))))

(define (fast-expt-iter b n)
  (define (iter acc b n)
    (cond (( = n 0)
           acc)
          ((even? n)
           (iter acc (square b) (/ n 2)))
          (else
           (iter (* acc b) b (- n 1)))))
  (iter 1 b n))

(~> (fast-expt 2 0)
    (check-equal? 1))
(~> (fast-expt 2 1)
    (check-equal? 2))
(~> (fast-expt 2 5)
    (check-equal? 32))
(~> (fast-expt 2 10)
    (check-equal? 1024))


(~> (fast-expt-iter 2 0)
    (check-equal? 1))
(~> (fast-expt-iter 2 1)
    (check-equal? 2))
(~> (fast-expt-iter 2 5)
    (check-equal? 32))
(~> (fast-expt-iter 2 10)
    (check-equal? 1024))