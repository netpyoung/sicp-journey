#lang sicp
;; file: 4_71.rkt

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(racket:require (racket:rename-in "../allcode/ch4-4.4.4.1-query.rkt"
                                  (_simple-query simple-query-before)
                                  (_disjoin disjoin-before)))

;; simple-query과 disjoin에서 delay시키느냐 안시키느냐의 차이.


;; simple-query
;; rule적용을 delay시키는데, 이상한 룰이 있으면 무한루프에 빠지게됨.


(~> '(
      
      (married Minnie Mickey)

      (rule (married ?x ?y)
            (married ?y ?x))
      
      )
    (initialize-data-base))

(define query
  '(married Mickey (? x))
  )

(~> (simple-query query (singleton-stream '()))
    (stream-car)
    (check-equal? '(((? 1 y) . Minnie) ((? x) ? 1 y) ((? 1 x) . Mickey))))

(define (simple-query-after query-pattern frame-stream)
  (stream-flatmap (lambda (frame)
                    ;; before
                    ;; (stream-append-delayed (find-assertions query-pattern frame)
                    ;;                        (delay (apply-rules query-pattern frame)))
                    ;;
                    ;; after
                    (stream-append (find-assertions query-pattern frame)
                                   (apply-rules query-pattern frame))
                    )
                  frame-stream))

(override-simple-query! simple-query-after)

;; endless loop
;;
;; (simple-query query (singleton-stream '()))


;; disjoin
;;
;; or 연산을 담당하는데, or의 두번째에 이상한걸 넣게되면 무한루프에 빠지게 됨.

(reset!)

(~> '(
      
      (married Minnie Mickey)

      (rule (married ?x ?y)
            (married ?y ?x))
      
      )
    (initialize-data-base))

(define query2
  '((married Mickey (? x)) (married (? x) 1))
  )

(~> (disjoin query2 (singleton-stream '()))
    (stream-car)
    (check-equal? '(((? 1 y) . Minnie) ((? x) ? 1 y) ((? 1 x) . Mickey))))

(define (disjoin-after disjuncts frame-stream)
  (if (empty-disjunction? disjuncts)
      the-empty-stream
      ;; before
      ;; (interleave-delayed (qeval (first-disjunct disjuncts) frame-stream)
      ;;                     (delay (disjoin (rest-disjuncts disjuncts) frame-stream)))
      (interleave (qeval (first-disjunct disjuncts) frame-stream)
                  (disjoin-after (rest-disjuncts disjuncts) frame-stream))
      ))

(override-disjoin! disjoin-after)


;; endless loop
;;
;; (disjoin query2 (singleton-stream '()))