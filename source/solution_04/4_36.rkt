#lang sicp
;; file: 4_36.rkt
;; 4_35, 4_37 

(#%require rackunit)
(#%require threading)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")

(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; 앞에 정의한 a-pythagorean-triple-between 함수에서 단순히 an-integer-between을 an-integer-starting-from로 바꿔서는 안됨.
;; 안되는 이유는?
;; an-integer-starting-from의 중첩으로는 깊이 우선 탐색으로 i j k가 1 1 1, 1 1 2, 1 1 3 .... 되면서 i가 올라가지 않게됨.
;; require는 조건을 걸러내는 필터일 뿐이고, 탐색 순서 자체를 바꿔주지는 못함.
;;
;; 올바른 해결책은?
;; 깊이 우선 탐색이므로 integer-starting-from만으로는 안됨. an-integer-between을 섞어 제한을 줘야함.

(define env3 (setup-environment))
(define-variable! '+ (list 'primitive +) env3)
(define-variable! '<= (list 'primitive <=) env3)
(define-variable! 'inc (list 'primitive inc) env3)
(define-variable! 'display (list 'primitive display) env3)
(~> '(define (require p)
       (if (not p)
           (amb)))
    (run env3)
    (check-equal? 'ok))

(~> '(define (an-integer-starting-from n)
       ;; (an-integer-starting-from 1)
       ;;=> amb (1 .....)
       (amb n
            (an-integer-starting-from (+ n 1))))
    (run env3)
    (check-equal? 'ok))

(~> '(define (an-integer-between from to)
       ;; 정해진 범위에서 정수 하나를 골라내는 프로시저.
       ;; (an-integer-between 1 10)
       ;;=> amb (1 2 3 4 5 6 7 8 9 10)
       (require (<= from to))
       (amb from
            (an-integer-between (inc from) to)))
    (run env3)
    (check-equal? 'ok))


(~> '(define (a-pythagorean-triple-from low)
       (let ((k (an-integer-starting-from low)))
         (let ((j (an-integer-between low k)))
           (let ((i (an-integer-between low j)))
             (require (= (+ (* i i) (* j j)) (* k k)))
             (list i j k)))))
    (run env3)
    (check-equal? 'ok))

(~> '(a-pythagorean-triple-from 1)
    (runs env3 10)
    (check-equal? '((3 4 5)
                    (6 8 10)
                    (5 12 13)
                    (9 12 15)
                    (8 15 17)
                    (12 16 20)
                    (15 20 25)
                    (7 24 25)
                    (10 24 26)
                    (20 21 29))))
