#lang sicp
;; file: 1_13.rkt

(define (fib n)
  (fib-iter 1 0 n))

(define (fib-iter a b count)
  (if (= count 0)
      b
      (fib-iter (+ a b) a (- count 1))))

(fib 10)

;; 1. Fib(n)이 φ = (1+√5)/2 에 가까운 정수 임을 증명해라. hint. ψ = (1-√5)/2
;;
;; https://en.wikipedia.org/wiki/Fibonacci_sequence#Binet's_formula
;;
;; Fib(n) = (φ^n)/√5
;;

;;
;; 2. Fib의 정의로 Fib(n) = (φ^n – ψ^n)/√5 임을 induction으로 밝혀라

;; induction.
;;  - 귀납법: 개별적인 사실들로부터 일반적인 결론을 이끌어내는 
;;    - 歸納(돌아갈 귀, 들일 납)
;;
;; Fib(0) = 0
;; Fib(1) = 1
;; Fib(n) = Fib(n-1) + Fib(n-2)
