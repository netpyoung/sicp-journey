#lang sicp
;; file: 4_35.rkt
;; 4_36, 4_37

(#%require rackunit)
(#%require threading)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")

(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; 정해진 범위에서 정수 하나를 골라내는 프로시저 an-integer-between을 정의하라.

(define env2 (setup-environment))
(~> '(define (require p)
       (if (not p)
           (amb)))
    (run env2)
    (check-equal? 'ok))

(~> '(begin
       (define (square x) (* x x))
       
       (define (smallest-divisor n)
         (find-divisor n 2))

       (define (find-divisor n test-divisor)
         (cond ((> (square test-divisor) n) n)
               ((divides? test-divisor n) test-divisor)
               (else (find-divisor n (+ test-divisor 1)))))

       (define (divides? a b)
         (= (remainder b a) 0))

       (define (prime? n)
         (= n (smallest-divisor n))))
    (run env2)
    (check-equal? 'ok))

(~> '(define (prime-sum-pair list1 list2)
       (let ((a (an-element-of list1))
             (b (an-element-of list2)))
         (require (prime? (+ a b)))
         (list a b)))
    (run env2)
    (check-equal? 'ok))
    
(~> '(define (an-element-of items)
       (require (not (null? items)))
       (amb (car items) 
            (an-element-of (cdr items))))
    (run env2)
    (check-equal? 'ok))

(~> '(prime-sum-pair '(1 3 5 8) '(20 35 110))
    (runs env2)
    (check-equal? '((3 20)
                    (3 110)
                    (8 35))))
(~> '(prime-sum-pair '(19 27 30) '(11 36 58))
    (run env2)
    (check-equal? '(30 11)))



;;
(define env3 (setup-environment))
(define-variable! '+ (list 'primitive +) env3)
(define-variable! '<= (list 'primitive <=) env3)
(define-variable! 'inc (list 'primitive inc) env3)
(~> '(define (require p)
       (if (not p)
           (amb)))
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

(~> '(define (a-pythagorean-triple-between low high)
       ;; i^2 + j^2 = k^2 인 세 정수의 쌍 (i, j , k)을 찾아네는 프로시져.
       (let ((i (an-integer-between low high)))
         (let ((j (an-integer-between i high)))
           (let ((k (an-integer-between j high)))
             (require (= (+ (* i i) (* j j)) (* k k)))
             (list i j k)))))
    (run env3)
    (check-equal? 'ok))

(~> '(a-pythagorean-triple-between 1 30)
    (runs env3)
    (check-equal? '((3 4 5)
                    (5 12 13)
                    (6 8 10)
                    (7 24 25)
                    (8 15 17)
                    (9 12 15)
                    (10 24 26)
                    (12 16 20)
                    (15 20 25)
                    (18 24 30)
                    (20 21 29))))
