#lang sicp
;; file: 1_17.rkt
;; 1_16 / 1_17 / 1_18

(#%require rackunit)

;; Mul구현. fast-expt처럼 계산단계가 로그로 자라도록 짜라.

(define (double x)
  (* 2 x))

(define (halve x)
  (/ x 2))

(define (mul a b)
  (if (= b 0)
      0
      (+ a (mul a (- b 1)))))

(define (fast-mul a b)
  (cond ((= b 0)
         0)
        ((even? b)
         (double (fast-mul a (halve b))))
        (else
         (+ a (fast-mul a (- b 1))))))


(check-equal? (mul 2 0)  0)
(check-equal? (mul 2 1)  2)
(check-equal? (mul 2 2)  4)
(check-equal? (mul 2 10) 20)
(check-equal? (mul 2 11) 22)

(check-equal? (fast-mul 2 0)  0)
(check-equal? (fast-mul 2 1)  2)
(check-equal? (fast-mul 2 2)  4)
(check-equal? (fast-mul 2 10) 20)
(check-equal? (fast-mul 2 11) 22)