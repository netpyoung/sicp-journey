#lang sicp
;; file: 4_42.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; Q. "Liars" 퍼즐을 풀어라.
;; Phillips, Hubert. 1934. The Sphinx Problem Book. London: Faber and Faber.
;;
;; 각각 참/거짓을 하나씩 말 할 수 있음.
;;
;; Betty: Kitty == 2 // Betty == 3
;; Ethel: Ethel == 1 // Joan  == 2
;; Joan : Joan  == 3 // Ethel == 5
;; Kitty: Kitty == 2 // Mary  == 4
;; Mary : Mary  == 4 // Betty == 1

(define expr-liars
  '(define (liars-puzzle)
     (let ((betty (amb 1 2 3 4 5))
           (ethel (amb 1 2 3 4 5))
           (joan  (amb 1 2 3 4 5))
           (kitty (amb 1 2 3 4 5))
           (mary  (amb 1 2 3 4 5)))
       (require (lie-or-true (= kitty 2) (= betty 3)))
       (require (lie-or-true (= ethel 1) (= joan  2)))
       (require (lie-or-true (= joan  3) (= ethel 5)))
       (require (lie-or-true (= kitty 2) (= mary  4)))
       (require (lie-or-true (= mary  4) (= betty 1)))
       (require (distinct? (list betty ethel joan kitty mary)))
       (list (list 'betty betty)
             (list 'ethel ethel)
             (list 'joan  joan )
             (list 'kitty kitty)
             (list 'mary  mary )))))

(define env3 (setup-environment))
(~> '(define (require p)
       (if (not p)
           (amb)))
    (run env3)
    (check-equal? 'ok))

(~> '(define (distinct? items)
       (cond ((null? items)
              true)
             ((null? (cdr items))
              true)
             ((member (car items) (cdr items))
              false)
             (else
              (distinct? (cdr items)))))
    (run env3)
    (check-equal? 'ok))

(~> '(define (lie-or-true x y)
       (not (eq? x y)))
    (run env3)
    (check-equal? 'ok))

(~> expr-liars
    (run env3)
    (check-equal? 'ok))

(racket:time
 (~> '(liars-puzzle)
     (runs env3)
     (check-equal? '(((betty 3) (ethel 5) (joan 2) (kitty 1) (mary 4))))))