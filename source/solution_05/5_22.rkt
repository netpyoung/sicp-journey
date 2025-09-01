#lang sicp
;; file: 5_22.rkt
;; 3_12 / 5_22
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
(#%require threading)

#|
연습문제 3.12에 나온 append와 append!에 대한 머신 설계.
|#


(racket:require "../allcode/ch5-regsim.rkt")

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



;; append =====================================================================

(define controller-append
  #|
  (define (append x y)
  (if (null? x)
      y
      (cons (car x) (append (cdr x) y))))
  |#
  '(BEGIN
    
    (assign continue (label END))
    
    LOOP
    (test (op null?) (reg x))                    ; (if (null? x)
    (branch
     (label CASE-y))
    
    (save continue)
    (assign continue (label AFTER-append-cdr))
    (save x)
    (assign x (op cdr) (reg x))                  ; prepare : (append (cdr x) y)
    (goto
     (label LOOP))                               ; do      : (append (cdr x) y)

    AFTER-append-cdr
    (restore x)
    (restore continue)
    (assign x (op car) (reg x))
    (assign val (op cons) (reg x) (reg val)) ; do : (cons (car x) (append (cdr x) y))))
    (goto
     (reg continue))
    
    CASE-y
    (assign val (reg y))
    (goto
     (reg continue))
    
    END))

(define machine-append
  (make-machine
   '(x y val continue)
   (list (list 'null? null?)
         (list 'car car)
         (list 'cdr cdr)
         (list 'cons cons)
         )
   controller-append
   ))

(define a1 '(1 2))
(define b1 '(3 4))
(~> machine-append
    (set-register-contents! 'x a1)
    (check-equal? 'done))
(~> machine-append
    (set-register-contents! 'y b1)
    (check-equal? 'done))
(~> machine-append
    (start)
    (check-equal? 'done))
(~> machine-append
    (get-register-contents 'val)
    (check-equal? '(1 2 3 4)))
(check-equal? a1 '(1 2))
(check-equal? b1 '(3 4))



;; append! =====================================================================
(define controller-append!
  '(BEGIN
    (assign iter-x (reg x))
    
    LOOP-last-pair
    (assign temp1 (op cdr) (reg iter-x))                    ; (if (null? (cdr x))
    (test (op null?) (reg temp1))
    (branch
     (label CASE-x))
    (assign iter-x (op cdr) (reg iter-x))
    (goto
     (label LOOP-last-pair))

    CASE-x
    (perform (op set-cdr!) (reg iter-x) (reg y))
    
    END))

(define machine-append!
  (make-machine
   '(x y iter-x temp1)
   (list (list 'null? null?)
         (list 'set-cdr! set-cdr!)
         (list 'cdr cdr)
         (list 'cons cons)
         )
   controller-append!
   ))

(define a2 '(1 2))
(define b2 '(3 4))
(~> machine-append!
    (set-register-contents! 'x a2)
    (check-equal? 'done))
(~> machine-append!
    (set-register-contents! 'y b2)
    (check-equal? 'done))
(~> machine-append!
    (start)
    (check-equal? 'done))
(~> machine-append!
    (get-register-contents 'x)
    (check-equal? '(1 2 3 4)))
(check-equal? a2 '(1 2 3 4))
(check-equal? b2 '(3 4))