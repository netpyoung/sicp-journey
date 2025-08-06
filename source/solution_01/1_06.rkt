#lang sicp
;; file: 1_06.rkt
(#%require threading)

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

(define (good-enough? guess x)
  (~> (square guess)
      (- x)
      (abs)
      (< 0.001)))

(define (sqrt x)
  (sqrt-iter 1.0 x))

;; ref: https://docs.racket-lang.org/reference/if.html#%28form._%28%28quote._~23~25kernel%29._if%29%29
;;
;; (if test-expr
;;     then-expr
;;     else-expr)
;; 
;; if는 Special form으로 predicate를 수행후 then이나 else를 수행한다.
;;
;; 하지만 new-if는 함수인데, Applicative-Order evaluation에서의 함수는 인자를 다 평가시켜버려서,
;; (sqrt-iter (improve guess x) x) 도 계속 실행시켜버려 메모리가 부족해져버린다.

(define (new-if predicate then-clause else-clause)
  (cond (predicate then-clause)
        (else else-clause)))

(define (sqrt-iter guess x)
  (new-if (good-enough? guess x)
          guess
          (sqrt-iter (improve guess x) x)))

;; #lang sicp에서는 Applicative-Order Evaluation이기에
(sqrt 9)
;;!> . Interactions disabled; out of memory

;; #lang lazy에서는 Lazy Evaluation이기에
(sqrt 9)
;;=> 3.00009155413138