#lang sicp
;; file: 4_73.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; flatten-stream 는 왜 delay 사용하나?
;; 계산을 미뤄 무한 스트림에 대한 무한루프 방지.
(racket:require (racket:rename-in "../allcode/ch4-4.4.4.1-query.rkt"
                                  (_flatten-stream flatten-stream-before)))


(define ones (cons-stream 1 ones))
(define twos (cons-stream 2 twos))



#;(flatten-stream (list->stream (list (list->stream '(1 2 3)) ones)))


(~> (flatten-stream (cons-stream (list->stream '(1 2 3)) ones))
    (stream-car)
    (check-equal? 1))

(define (flatten-stream-after stream)
  ;; before
  ;; (if (stream-null? stream)
  ;;     the-empty-stream
  ;;     (interleave-delayed (stream-car stream)
  ;;                         (delay (flatten-stream (stream-cdr stream)))))

  ;; after
  (if (stream-null? stream)
      the-empty-stream
      (interleave (stream-car stream)
                  (flatten-stream-after (stream-cdr stream)))))

(override-flatten-stream! flatten-stream-after)

;; 무한 루프
;; (~> (flatten-stream (cons-stream (list->stream '(1 2 3)) ones))
;;     (stream-car)
;;     (check-equal? 1))
