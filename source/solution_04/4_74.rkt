#lang sicp

;; file: 4_74.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;;
;; simple-flatten을 구현하라

(racket:require "../allcode/ch4-4.4.4.1-query.rkt")

(define (simple-stream-flatmap proc s)
  (simple-flatten (stream-map proc s)))

(define (simple-flatten stream)
  (stream-map stream-car
              (stream-filter (lambda (s)
                               (not (stream-null? s)))
                             stream)))

'(define (flatten-stream stream)
   (if (stream-null? stream)
       the-empty-stream
       (interleave-delayed (stream-car stream)
                           (delay (flatten-stream (stream-cdr stream))))))



(define test-stream
  (list->stream (list (list->stream '(1))
                      (list->stream '(2))
                      (list->stream '())
                      (list->stream '(3)))))

(~> (flatten-stream test-stream)
    (stream->list )
    (check-equal?'(1 2 3)))

(~> (simple-flatten test-stream)
    (stream->list )
    (check-equal?'(1 2 3)))


(override-flatten-stream! flatten-stream)
(override-stream-flatmap! simple-stream-flatmap)

;; 쿼리 시스템의 행동이 달라지는가?
;; 달라지지 않는다.
;; frame 스트림에 프로시저를 적용하면 언제나 빈 스트림이나 원소 한 개짜리 스트림이 나오므로, 스트림을 번갈아 끼워넣을 필요가 없다.
