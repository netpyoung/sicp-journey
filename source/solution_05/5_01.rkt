#lang sicp
;; file: 5_01.rkt
;; 5_01 / 5_02

;;
;; ref:
;; Figure 5.3: A specification of the GCD machine. (data-path + controller)
;; Figure 5.4: A GCD machine that reads inputs and prints results. (gdc + read / print)
;; 5.2 A Register-Machine Simulator - (define gcd-machine ...)


;; TODO Draw data-path and controller diagrams for this machine.
'(define (factorial n)
   (define (iter product counter)
     (if (> counter n)
         product
         (iter (* counter product)
               (+ counter 1))))
   (iter 1 1))
