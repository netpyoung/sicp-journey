#lang sicp
;; file: 4_14.rkt

(#%require rackunit)
(#%require threading)
(#%require (prefix racket: racket))
(#%require (prefix r5rs: r5rs))

(racket:require "../allcode/ch4-4.1.1-mceval.rkt")
;;
;; 1. Eva Lu Ator은 map의 정의를 직접 입력해서 평가하는 방식.
;; 2. Louis Reasoner는 map을 primitive-procedures에 넣어 버리는 방식.
;; Eva Lu Ator는 잘 동작하는데, Louis Reasoner는 동작하지 않는 이유는?
;;
;; env는
;; 1에서의 map은 (procedure (proc items) ((if (null? items) '() ...) 형태로 저장
;; 2에서의 map은 (primitive #<procedure:mcar>) 형태로 저장.
;; 작성한 eval&apply과정에서 사용하는 데이터가 r5rs에서의 과정과 사용하는 데이터가 맞지않음.

;; 1. Eva Lu Ator (aka, Evaluator) 방식
;;

(define env1 (setup-environment))
(check-equal? (eval '(define (map proc items)
                       (if (null? items)
                           '()
                           (cons (proc (car items))
                                 (map proc (cdr items)))))
                    env1)
              'ok)
(check-equal? (eval '(map car '((a 1) (b 2) (c 3))) env1)
              '(a b c))

;; 2. Louis Reasoner (akka, loose reasoner)
;;
(define env2 (setup-environment))
(define-variable! 'map (list 'primitive map) env2) ; 아니면 primitive-procedures를 직접 수정.

(check-exn
 racket:exn:fail?
 (lambda ()
   ;; (r5rs:apply map (list (list 'primitive car) '((a 1) (b 2) (c 3)))) 와 같음.
   ;; application: not a procedure;
   ;;  expected a procedure that can be applied to arguments
   ;;   given: (primitive #<procedure:mcar>)
   (eval '(map car '((a 1) (b 2) (c 3))) env2)))

