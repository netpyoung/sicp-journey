#lang sicp
;; file: 1_03.rkt

(#%require rackunit)
(#%require threading)

(define (square x)
  (* x x))

(define (sum-of-squares x y)
  (+ (square x) (square y)))

(define (ex1-03 a b c)
  (cond ((and (< a b) (< a c))
         (sum-of-squares b c))
        ((< b c)
         (sum-of-squares a c))
        (else
         (sum-of-squares a b))))
  
(check-equal? (ex1-03 2 10 3) 109)



(define first car)
(define rest cdr)

(define (filter pred? sequence)
  (cond ((null? sequence) '())
        ((pred? (first sequence))
         (cons (first sequence) (filter pred? (rest sequence))))
        (else
         (filter pred? (rest sequence)))))

(define (sort less-than? lst)
  (if (or (null? lst) (null? (rest lst)))
      lst
      (let* ((pivot (first lst))
             (rest (rest lst))
             (smaller (filter (lambda (x) (less-than? x pivot)) rest))
             (greater-equal (filter (lambda (x) (not (less-than? x pivot))) rest)))
        (append (sort less-than? smaller)
                (cons pivot (sort  less-than? greater-equal))))))

(define (take n sequence)
  (cond ((<= n 0) '())
        ((null? sequence) '())
        (else (cons (first sequence)
                    (take (- n 1) (rest sequence))))))

(define (largest-squares n xs)
  (~>> xs
       (sort >)
       (take n)
       (map (lambda (x) (* x x)))
       (apply +)))


(check-equal? (largest-squares 2 '(2 10 3)) 109)