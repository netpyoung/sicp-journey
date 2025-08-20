#lang sicp
;; file: 4_34.rkt
(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require "../allcode/helper/my-util.rkt")

(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.2.2-leval.rkt"
                                  (_eval-sequence lazy:eval-sequence)))

;; TODO
;; driver loop를 수정하여 lazy pair / lazy list를 보기 좋게 출력해라.(무한 리스트는 어떻게 다룰 것인가?)
;; evaluator가 lazy pairs를 잘 인식하여 출력하도록, lazy pairs를 내부적으로 어떻게 다를 것인지에 대해 수정해야 할 지도 모른다.

(define env1 (setup-environment))
(~> '(begin
       (define (cons x y)
         (lambda (m)
           (m x y)))
       (define (car z)
         (z
          (lambda (p q) p)))
       (define (cdr z)
         (z
          (lambda (p q) q))))
    (actual-value env1)
    (check-equal? 'ok))

(~> '(cons nil nil)
    (actual-value env1))

#;(~> '(cons 1 (cons 2 '()))
    (actual-value env1))