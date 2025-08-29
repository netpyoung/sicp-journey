#lang sicp

(#%require (prefix racket: racket))
(racket:require "my-macro.rkt")

(racket:provide (racket:all-defined-out))
(racket:provide (racket:all-from-out "my-macro.rkt"))

(define first car)
(define rest cdr)
(define second cadr)
(define third caddr)
(define fourth cadddr)


;; TODO - naming
;; (define cons-item1 car)
;; (define cons-item2 cdr)
;;  set-car!
;;  set-cdr!
