#lang sicp
;; file: 1_11.rkt

;; n <  3 : f(n) = n                        
;; n >= 3 : f(n) = f(n-1) + 2f(n-2) + 3f(n-3)   

(define (f-recur n)
  (cond ((< n 3) n)
        (else    (+ (f-recur (- n 1))
                    (* 2 (f-recur (- n 2)))
                    (* 3 (f-recur (- n 3)))))))



;;      |  p1    |   p2    |   p3   |
;; f(n) = f(n-1) + 2f(n-2) + 3f(n-3)
;; ...
;; f(4) = f(3) + 2f(2) + 3f(1) = (2 + 2*1 + 3*0) + 2*2 + 3*1 = 11
;; f(3) = f(2) + 2f(1) + 3f(0) =  2              + 2*1 + 3*0 = 4
;; f(2) = 2
;; f(1) = 1
;; f(0) = 0

(define (iter curr-n target-n fn-1 fn-2 fn-3)
  (let ((next-fn-1 (+ fn-1 (* 2 fn-2) (* 3 fn-3)))
        (next-fn-2 fn-1)
        (next-fn-3 fn-2))
    (if (= curr-n target-n)
        next-fn-1
        (iter (inc curr-n) target-n next-fn-1 next-fn-2 next-fn-3))))

(define (f-iter n)
  (if (< n 3)
      n
      (iter 3 n 2 1 0)))



(#%require (prefix racket/ racket))
(#%require rackunit)
(racket/for ([i 20])
            (check-eq? (f-recur i)(f-iter i)))