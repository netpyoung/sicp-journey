#lang sicp
;; file: 4_76.rkt
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; TODO and의 두번째 쿼리를처리하는 과정에서 첫 번째 쿼리가 만들어낸 모든 일람표에 대해 데이터베이스를 훌어보아야 하기 때문에 효율이 떨어진다.
;; 이와달리, and의 두절을 따로 처리한 다음에, 출력 일람표들의 모든쌍이 서로 어긋나지 않는지 살펴보는 방법도 있다.
;; 그리하려면, 두 일람표를 인자로 받아, 두 일람표 속의 정의가 서로 맞아떨어진다면 두 정의를 한데 합쳐 하나의 일람표를 만들어내는 프로시저를 짜야한다.
;; 이 연산은 unification과 유사하다.


(racket:require "../allcode/ch4-4.4.4.1-query.rkt")

(~> microshaft-data-base
    (initialize-data-base))

(define (conjoin-origin conjuncts frame-stream)
  (if (empty-conjunction? conjuncts)
      frame-stream
      (conjoin-origin (rest-conjuncts conjuncts)
                      (qeval (first-conjunct conjuncts)
                             frame-stream))))

(put 'and 'qeval conjoin-origin)


(define (conjoin-after conjuncts frame-stream)
  (if (empty-conjunction? conjuncts)
      frame-stream
      (conjoin-after (rest-conjuncts conjuncts)
                     (qeval (first-conjunct conjuncts)
                            frame-stream))))

(put 'and 'qeval conjoin-after)