#lang sicp
;; file: 4_62.rkt
;; 2_17 / 4_62 / 4_63 / 4_69

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.4.4.1-query.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

(racket:provide
 rules-last-pair)

;; Q. 연습문제 2.17에 나온 last-pair를 rule로 만들어라.
;;
;; - 연습문제 2.17
;;   - last-pair: 마지막 요소가 포함된 리스트를 반환하는 함수
;;   - (last-pair (list 23 72 149 34)) ;=> (34)
;;

(define rules-last-pair
  '(
    ;; (last-pair ?lst (?last-elem)) : ?lst에서 ?last-elem을 찾음
    (rule (last-pair (?x) (?x)))       ; == (rule (last-pair (?x . ()) (?x . ())))
    (rule (last-pair (?x . ?y) ?z)
          (last-pair ?y ?z))
    )
  )

(~> microshaft-data-base
    (append rules-last-pair)
    (initialize-data-base))

(~> '(last-pair (3) ?x)
    (run)
    (check-equal? '((last-pair (3) (3)))))

(~> '(last-pair (1 2 3) ?x)
    (run)
    (check-equal? '((last-pair (1 2 3) (3)))))

(~> '(last-pair (2 ?x) (3))
    (run)
    (check-equal? '((last-pair (2 3) (3)))))

;; Q. (last-pair ?x (3)) 와 같은 것에도 제대로 동작하나?
;; 제약조건인 ?x가 미지수이기에 결과를 제대로 얻지못함.