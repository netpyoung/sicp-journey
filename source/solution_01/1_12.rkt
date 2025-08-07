#lang sicp
;; file: 1_12.rkt

;; 파스칼 삼각형

(define (P x y)
  (cond ((zero? x) 1)
        ((= x y)   1)
        (else      (+ (P (- x 1) y)
                      (P (- x 1) (- y 1))))))



(#%require (prefix racket/ racket))
(racket/for ([y (racket/in-inclusive-range 0 5)])
            (display y)
            (display ": ")
            (racket/for ([x (racket/in-inclusive-range 0 y)])
                        (display (P x y))
                        (display " "))
            (newline))
;;>> 0: 1 
;;>> 1: 1 1 
;;>> 2: 1 2 1 
;;>> 3: 1 2 4 1 
;;>> 4: 1 2 4 8 1 
;;>> 5: 1 2 4 8 16 1 