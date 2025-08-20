#lang sicp
;; file: 4_37.rkt
;; 4_35, 4_36
(#%require rackunit)
(#%require threading)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; Ben Bitdiddle 는 4.35에서 나온 a-pythagorean-triple-between보다 자신의 것이 더 효율적이라고 주장하는데, 사실인가?
;; (힌트, 탐색해야할 가능성의 수 고려)

(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))



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

;; 4.35
'(define (a-pythagorean-triple-between low high)
   ;; i^2 + j^2 = k^2 인 세 정수의 쌍 (i, j , k)을 찾아네는 프로시져.
   ;; an-integer-between가 3개 O(n^3)
   (let ((i (an-integer-between low high)))
     (let ((j (an-integer-between i high)))
       (let ((k (an-integer-between j high)))
         (require (= (+ (* i i) (* j j)) (* k k)))
         (list i j k)))))

;; 4.37
(~> '(define (a-pythagorean-triple-between-37 low high)
       ;; an-integer-between가 2개 O(n^2)
       (let ((i (an-integer-between low high))
             (hsq (* high high)))
         (let ((j (an-integer-between i high)))
           (let ((ksq (+ (* i i)
                         (* j j))))
             (require (<= ksq hsq))
             (let ((k (sqrt ksq)))
               (require (integer? k))
               (list i j k))))))
    (run env3)
    (check-equal? 'ok))

(~> '(a-pythagorean-triple-between-37 1 50)
    (runs env3 10)
    (check-equal? ' ((3 4 5)
                     (5 12 13)
                     (6 8 10)
                     (7 24 25)
                     (8 15 17)
                     (9 12 15)
                     (9 40 41)
                     (10 24 26)
                     (12 16 20)
                     (12 35 37))))
