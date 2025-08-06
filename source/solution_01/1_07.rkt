#lang sicp
;; file: 1_07.rkt
(#%require threading)
(#%require (prefix racket/ racket))
(#%require rackunit)

;; 1.1.7 연습: 뉴튼 법으로 제곱근 찾기

(define (square x)
  (* x x))

#;(define (sqrt-iter guess x)
    (if (good-enough? guess x)
        guess
        (sqrt-iter (improve guess x) x)))

(define (improve guess x)
  (average guess (/ x guess)))

(define (average x y)
  (~> (+ x y) 
      (/ 2)))

#;(define (good-enough? guess x)
    (~> (square guess)
        (- x)
        (abs)
        (< 0.001)))

(define (sqrt x)
  (sqrt-iter 1.0 x))


;; ========================================
;; 중요한거. 번역판을 읽으면 이 문제를 풀기 어려워진다.
;; 원문을 읽어야 이 문제를 보다 풀기가 쉬워진다.
;;
;; An alternative strategy for implementing good-enough? is to watch how guess changes from one iteration to the next
;; and to stop when the change is a very small fraction of the guess.
;; 반복할 때마다 `guess`의 **변화량**를 살펴보고,
;; `guess`에 **변화량**이 **아주 작은** 비율이 되었을 때 멈추는 것이다.
(define DECIMAL-EPSILON
  (let loop ([e 1.0])
    (if (= (+ 1.0 e) 1.0)
        (* 2 e)
        (loop (/ e 2)))))

(define VERY-SMALL-RADIO DECIMAL-EPSILON)
;; (define VERY-SMALL-RADIO 0.00000000001)

VERY-SMALL-RADIO
;;=> 2.220446049250313e-16

(define (good-enough? guess next-guess)
  (let ((diff (- guess next-guess)))
    (~> (/ diff next-guess)
        (abs)
        (< VERY-SMALL-RADIO))))

(define (sqrt-iter guess x)
  (let ((next-guess (improve guess x)))
    (if (good-enough? guess next-guess)
        guess
        (sqrt-iter next-guess x))))

;; 아주 큰 수의 제곱근을 잘 구하는가?
;; 아주 작은 수 의 제곱근을 잘 구하는가?
(define COMPARE-EPSILON 0.00000001)
(check-= (sqrt 0.00000000123456) (racket/sqrt 0.00000000123456) COMPARE-EPSILON)
(check-= (sqrt 123456789012345) (racket/sqrt 123456789012345) COMPARE-EPSILON)


;; ref: https://sicp-solutions.net/post/sicp-solution-exercise-1-7/