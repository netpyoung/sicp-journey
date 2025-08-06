#lang sicp
;; file: 1_08.rkt
(#%require threading)
(#%require (prefix racket/ racket))
(#%require rackunit)

;; imporve 가 바뀌고 나머지는sqrt를 구할때와 거의 비슷한 흐름으로 흘러간다.
(define (improve guess x)
  "( x/y^2 + 2y ) / 3"
  (/ (+ (/ x (* guess guess)) (* 2 guess)) 3))

(define VERY-SMALL-RADIO 0.00000000001)

(define (good-enough? guess next-guess)
  (let ((diff (- guess next-guess)))
    (~> (/ diff next-guess)
        (abs)
        (< VERY-SMALL-RADIO))))


(define (cube-root-iter guess x)
  (let ((next-guess (improve guess x)))
    (if (good-enough? guess next-guess)
        guess
        (cube-root-iter next-guess x))))

(define (cube-root x)
  (cube-root-iter 1.0 x))

(define (cube x)
  (* x x x))

(define COMPARE-EPSILON 0.00000001)
(check-= 12345 (cube (cube-root 12345)) COMPARE-EPSILON)
