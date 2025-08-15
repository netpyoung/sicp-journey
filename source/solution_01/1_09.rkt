#lang debug sicp
;; file: 1_09.rkt

(define (x+ a b)
  (if (= a 0)
      b
      (inc (x+ (dec a) b))))

;; (x+ 2 1)
;; (inc (x+ 1 1))
;; (inc (inc (x+ 0 1)))
;; (inc (inc 1))
;; (inc 2)
;;=> 3

(define (y+ a b)
  (if (= a 0)
      b
      (y+ (dec a) (inc b))))

;; (y+ 2 1)
;; (y+ 1 2))
;; (y+ 0 3)
;;=> 3

(#%require (prefix trace: racket/trace))
(trace:trace x+)
(trace:trace y+)

(display "x+ ==============================\n")
(x+ 2 1)
;;>> >{x+ 2 1}
;;>> > {x+ 1 1}
;;>> > >{x+ 0 1}
;;>> < <1
;;>> < 2
;;>> <3
;;=> 3
(display "y+ ==============================\n")
(y+ 2 1)
;;>> >{y+ 2 1}
;;>> >{y+ 1 2}
;;>> >{y+ 0 3}
;;>> <3
;;=> 3