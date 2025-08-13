#lang sicp
;; file: 4_19.rkt


;; (let ((a 1))
;;   (define (f x)
;;     (define b (+ a x))
;;     (define a 5)
;;     (+ a b))
;;   (f 10))

;; Ben Bitdiddle 의견
;; 순차적 규칙(sequential rule) - c / python ...
;; a = 1  (let ((a 1))
;; x = 10 (f 10)
;; b = 11 (+ a x)
;; a = 5
;; 
;; (+ a b) => 16

;; Alyssa P. Hacker 의견
;; 동시 범위(simultaneous scope) 규칙 - scheme
;; a = 1  (let ((a 1))
;; x = 10 (f 10)
;; b = *unassigned*
;; a = *unassigned*
;; b = 에러발생 (+ *unassigned* x)

;; Eva Lu Ator 의견
;; Layzy Evaluation - haskell / OCaml ...
;; a = 1  (let ((a 1))
;; x = 10 (f 10)
;; b = lazy(+ a x)
;; a = 5
;; 
;; (+ a b) = 5 + lazy(+ a x)
;;         = 5 + (+ 5 10)
;;         = 20


;; 1. 세 가지 관점 중 어느 것(또는 어느 것도 아닌 것)을 지지하는가?
;; 살짝 정적 분석같은 기믹도 가미된 Alyssa P.
;;
;; 2. Eva Lu Ator 의견에 따라 동작하도록 구현할 수 있는가?
;; 정의부를 lambda식으로 감싸 실제 필요할때 평가도록 하면 될꺼같은데...


