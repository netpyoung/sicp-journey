#lang lazy
;; file: 1_05.rkt

(define (p)
  (p))
(define (test x y)
  (if (= x 0)
      0
      y))

(test 0 (p))
;;=> 0

;; #lang sicp 라면 y로 들어온 (p)가 무한히 호출됨.
;; #lang lazy 라면 y를 평가하지 않아 0이 반환.
;; #lang lazy는 엄밀히 말하면 Lazy Evaluation인데 normal-order evaluation에 캐쉬를 단거라 생각하면됨.

