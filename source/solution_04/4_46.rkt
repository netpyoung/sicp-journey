#lang sicp
;; file: 4_46.rkt
;; 4_45 / 4_46 / 4_47 / 4_48 / 4_49

;; 4.1(meval)과 4.2(leval)의 평가자는 피연산자(operand)가 평가되는 순서를 결정하지 않는다.
;; amb evaluator는 피연산자를 왼쪽에서 오른쪽으로 평가한다
;; Q. 피연산자를 다른 순서로 평가하면 파싱 프로그램이 동작하지 않는데, 그 이유는?
;;
;; parse가 *unparsed*를 사용하여 왼쪽에서 오른쪽으로 이동.
;; parse-sentense시 operand순서가 바뀌면 parse-noun-phrase보다 parse-word가 먼저 실행되어 구문 평가에 에러가 날것임.

'(define (parse input)
   (set! *unparsed* input)
   ...)

'(define (parse-word word-list)
   ...
   (set! *unparsed* (cdr *unparsed*))
   ...)

'(define (parse-sentence)
   ;; sentence: 문장
   (list 'sentence
         (parse-noun-phrase)
         (parse-word verbs)))