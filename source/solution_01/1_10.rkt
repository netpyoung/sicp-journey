#lang sicp
;; file: 1_10.rkt

(define (A x y)
  ;; A(x, 0) = 0
  ;; A(0, y) = 2y
  ;; A(x, 1) = 2
  ;; A(x, y) = A(x-1, A(x, y-1))
  (cond ((= y 0) 0)
        ((= x 0) (* 2 y))
        ((= y 1) 2)
        (else   (A (- x 1) (A x (- y 1))))))

(A 1 10)
;;=> 1024
(A 2 4)
;;=> 65536
(A 3 3)
;;=> 65536
(A 4 2)
;;=> 4


(define (f n) (A 0 n))
;; A(0, y) = 2y
;; f(n) = 2n

(define (g n) (A 1 n))
;; A(1, n-0)
;; = 2 * A(1, n-1)
;; = 2 * 2 * A(1, n-2)
;; = 2 * 2 * ... * A(1, n-(n- 1))
;; = 2 * 2 * ... * 2
;; g(n) = 2^n

(define (h n) (A 2 n))
;; 2^2^2 or 2^h(n-1)
;; A(2, n - 0)
;; = A(1, A(2, n-1))
;; = A(1, A(1, A(2, n-2))
;; = A(1, A(1, A(1, ... A(1, A(2, n-(n-1))))
;; h(n) = 2^2^2....2 (2의 갯수는 n개)
;; h(n) = pow(2, h(n-1))

(define (k n) (* 5 n n))
;; k(n) = 5n^2


;; Primitive Recursive Function = 반복 횟수가 미리 정해져 있어서 for문 같은 단순 반복으로 구현 가능 (factorial같은거)
;; Ackermann은 'for' 문 같은 구조로는 표현할 수 없는 함수도 있다는걸 보여주기 위해 Ackermann함수를 만듬.
;; 재귀 깊이가 입력값에 따라 아주 빠르게 늘어나서, 고정된 반복 횟수로 미리 제한하는 'for'문으로는 표현하기 힘듬.
;;
;; ref:
;;   - https://en.wikipedia.org/wiki/Ackermann_function
;;   - https://plato.stanford.edu/Entries/recursive-functions/ackermann-peter.html
;;   - https://sites.google.com/site/pointlesslargenumberstuff/home/2/ackermann

;; Ackermann original function
(define (φ x y z)
  ;; φ(x, y, 0) = x + y
  ;; φ(x, 0, z) = α(x, z-1)
  ;; φ(x, y, z) = φ(x, φ(x, y-1, z) z-1)
  (cond ((= z 0) (+ x y))
        ((= y 0) (α x (- z 1)))
        (else    (φ x (φ x (- y 1) z) (- z 1)))))

(define (α x y)
  ;; α(x, 0) = 0
  ;; α(x, 1) = 1
  ;; α(x, y) = x
  (cond ((= y 0) 0)
        ((= y 1) 1)
        (else    x)))

;; Ackermann-Peter function
(define (C m n)
  ;; C(0, n) = n+1
  ;; C(m, 0) = C(m-1, 1)
  ;; C(m, n) = C(m-1, C(m, n-1))
  (cond ((= m 0) (+ n 1))
        ((= n 0) (C (- m 1) 1))
        (else    (C (- m 1) (C m (- n 1))))))

(#%require (prefix trace/ racket/trace))
(trace/trace φ)
(trace/trace C)
(φ 1 2 3)
(C 2 1)
