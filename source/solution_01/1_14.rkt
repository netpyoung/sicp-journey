#lang sicp
;; file: 1_14.rkt
(#%require (prefix trace: racket/trace))

;; 1.2.2: count-change
(define (count-change amount)
  (cc amount 5))

(define (cc amount kinds-of-coins)
  (cond ((= amount 0)
         1)
        ((or (< amount 0) (= kinds-of-coins 0))
         0)
        (else
         (+ (cc amount (- kinds-of-coins 1))
            (cc (- amount (first-denomination kinds-of-coins)) kinds-of-coins)))))

(define (first-denomination kinds-of-coins)
  (cond ((= kinds-of-coins 1) 1)
        ((= kinds-of-coins 2) 5)
        ((= kinds-of-coins 3) 10)
        ((= kinds-of-coins 4) 25)
        ((= kinds-of-coins 5) 50)))

(count-change 100)
;;=> 292

(trace:trace cc)
(count-change 11)
;;=> 4
;;
;; 1. 10x 1 +  1x 1
;; 2.  5x 1 +  1x 6
;; 3.  5x 2 +  1x 1
;; 4.  1x11

;; amount가 증가함에 따라 사용되는 공간과 수행 단계의 증가 차수는?
;;
;; 1. 수행 단계 수 (시간 복잡도)
;; - https://en.wikipedia.org/wiki/Time_complexity
;;
;; - 얼핏보면: O(2^n)
;;   - cc안에서 cc가 두번 호출. 호출 트리가 이진 트리처럼 보임
;; - 사실은: O(n^5)
;;   - amount뿐만 아니라 동전 종류도 고려되야함.
;;   - 그리고 cc를 보면 중복호출하는데 이 중복 계산도 포함하게 되면 - O(n^k)
;;   - 메모이제이션이나 동적 계획법으로 풀면 O(n*k) 복잡도는 줄어들 수 있음.
;;
;; 2. 공간 사용량 (공간 복잡도)
;; - https://en.wikipedia.org/wiki/Space_complexity
;;
;; - 선형 O(n)
;;   - amount가 지속적 감소 ( 최대 호출 스택 깊이 )