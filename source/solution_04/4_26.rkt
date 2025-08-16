#lang sicp
;; file: 4_26.rkt
;; 4_06

(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require (prefix racket: racket))
;; lazy evaluation <=> eager evaluation


(define (unless condition usual-value exceptional-value)
  (if condition
      exceptional-value
      usual-value))

;; Ben Bitdidle
;;  - lazy evaluation의 중요성에 공감 못함. 그냥 eager evaluation환경에서 unless를 스페셜 폼으로 구현하면 된다.
;;
;; unless 를 (앞선 cond 혹은 let 처럼) derived expression 구현
;;
(define (unless->if expr)
  (let ((condition (second expr))
        (usual-value (third expr))
        (exceptional-value (fourth expr)))
    (list 'if condition
          exceptional-value
          usual-value)))

(check-equal?
 (unless->if '(unless (= 1 0)
                10
                20))
 '(if (= 1 0)
      20
      10))

;; Alyssa P. Hacker
;; - 그렇게 하면 함수를 인자나 반환값으로 사용하는 high-order procedure에서 사용 못한다.
;;
;; unless가 procedure로 사용되면 유용한 예.
;;

(check-equal? (map unless (list true false true) '(1 1 1) '(2 2 2))
              '(2 1 2))