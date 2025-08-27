#lang sicp
;; file: 1_18.rkt
;; 1_16 / 1_17 / 1_18

(#%require rackunit)

;; Mul구현. 1.16와 1.17를 합쳐 계산 단계가 로그로 자라되 iterative형태로 짜라.

(define (double x)
  (* 2 x))

(define (halve x)
  (/ x 2))


(define (fast-mul-iter a b)
  (define (iter acc a b)
    (cond ((= b 0)
           acc)
          ((even? b)
           (iter acc (double a) (halve b)))
          (else
           (iter (+ acc a) a (- b 1)))))
  (iter 0 a b))


(check-equal? (fast-mul-iter 2 0)  0)
(check-equal? (fast-mul-iter 2 1)  2)
(check-equal? (fast-mul-iter 2 2)  4)
(check-equal? (fast-mul-iter 2 10) 20)
(check-equal? (fast-mul-iter 2 11) 22)