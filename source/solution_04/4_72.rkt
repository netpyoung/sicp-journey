#lang sicp
;; file: 4_72.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; 왜 disjoin 와 stream-flatmap에서 스트림을 병합할때 append가 아닌 interleave를 사용하는가?
(racket:require "../allcode/ch4-4.4.4.1-query.rkt")

'(define (disjoin disjuncts frame-stream)
   (if (empty-disjunction? disjuncts)
       the-empty-stream
       (interleave-delayed (qeval (first-disjunct disjuncts) frame-stream)
                           (delay (disjoin (rest-disjuncts disjuncts) frame-stream)))))

'(define (stream-flatmap proc s)
   (flatten-stream (stream-map proc s)))


'(define (flatten-stream stream)
   (if (stream-null? stream)
       the-empty-stream
       (interleave-delayed (stream-car stream)
                           (delay (flatten-stream (stream-cdr stream))))))

'(define (interleave-delayed s1 delayed-s2)
   (if (stream-null? s1)
       (force delayed-s2)
       (cons-stream (stream-car s1)
                    (interleave-delayed (force delayed-s2)
                                        (delay (stream-cdr s1))))))


'(define (stream-append-delayed s1 delayed-s2)
   (if (stream-null? s1)
       (force delayed-s2)
       (cons-stream (stream-car s1)
                    (stream-append-delayed (stream-cdr s1)
                                           delayed-s2))))


(define ones (cons-stream 1 ones))
(define twos (cons-stream 2 twos))

;; append시 첫번째 스트림이 무한일때, 두번째 스트림에 접근이 불가.
(~> (stream-append-delayed ones (delay twos))
    (stream-cdr)
    (stream-cdr)
    (stream-cdr)
    (stream-car)
    (check-equal? 1))

;; interleave면 첫번째 스트림이 무한이라도 번갈아 기회가 생김.
(~> (interleave-delayed ones (delay twos))
    (stream-cdr)
    (stream-cdr)
    (stream-cdr)
    (stream-car)
    (check-equal? 2))