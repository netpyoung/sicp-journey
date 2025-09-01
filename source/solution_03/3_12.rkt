#lang sicp
;; file: 3_12.rkt
;; 3_12 / 5_22
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

;; TODO

(define (append x y)
  (if (null? x)
      y
      (cons (car x) (append (cdr x) y))))

(define (append! x y)
  (set-cdr! (last-pair x) y)
  x)

(define (last-pair x)
  (if (null? (cdr x))
      x
      (last-pair (cdr x))))

(define x1 '(1 2))
(define y1 '(3 4))
(check-equal? (append x1 y1)
              '(1 2 3 4))
(check-equal? x1 '(1 2))
(check-equal? y1 '(3 4))

(define x2 '(1 2))
(define y2 '(3 4))
(check-equal? (append! x2 y2)
              '(1 2 3 4))
(check-equal? x2 '(1 2 3 4))
(check-equal? y2 '(3 4))