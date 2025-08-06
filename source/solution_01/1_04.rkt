#lang sicp
;; file: 1_04.rkt

(define (a-plus-abs-b a b)
  ((if (> b 0)
       +
       -)
   a b))


(a-plus-abs-b 2 7)
;;=> 9

(a-plus-abs-b 2 -7)
;;=> 9


(a-plus-abs-b -2 7)
;;=> 5

(a-plus-abs-b -2 -7)
;;=> 5