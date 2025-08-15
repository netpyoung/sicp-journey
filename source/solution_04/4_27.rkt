#lang sicp
;; file: 4_27.rkt
(#%require rackunit)
(#%require threading)
(#%require (prefix racket: racket))

(racket:require (racket:except-in "../allcode/ch4-4.1.1-mceval.rkt"
                                  eval
                                  input-prompt
                                  primitive-procedures
                                  apply
                                  eval-if
                                  output-prompt
                                  driver-loop))
(racket:require "../allcode/ch4-4.2.2-leval.rkt")

;; lazy evaluator는 eval후 force it을 적용.
;; (driver-loop) 후 입력해도 됨.
;;
;; (define (actual-value exp env)
;;   (force-it (eval exp env)))
;;

(define env1 (setup-environment))
(~> '(define count 0)
    (actual-value env1)
    (check-eq? 'ok))

(~> '(define (id x)
       (set! count (+ count 1))
       x)
    (actual-value env1)
    (check-eq? 'ok))

(~> '(define w (id (id 10)))
    (actual-value env1)
    (check-eq? 'ok))

(~> 'count
    (actual-value env1)
    (check-eq? 1))

(~> 'w
    (actual-value env1)
    (check-eq? 10))

(~> 'count
    (actual-value env1)
    (check-eq? 2))