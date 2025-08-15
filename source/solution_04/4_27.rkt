#lang sicp
;; file: 4_27.rkt
(#%require (prefix racket: racket))

(racket:require (racket:except-in "../allcode/ch4-4.1.1-mceval.rkt"
                                  eval
                                  input-prompt
                                  primitive-procedures
                                  ;;driver-loop
                                  apply
                                  eval-if
                                  output-prompt))
#;(racket:require "../allcode/ch4-4.2.2-leval.rkt")

;; lazy evaluator( 제때 실행기  WTF )

(define count 0)
(define (id x)
  (set! count (+ count 1))
  x)

(define w (id (id 10)))
