#lang sicp
;; file: 4_39.rkt
;; 4_38, 4_39, 4_40, 4_41
(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))


;; Q. multiple-dwelling에서 require의 순서가 답에 영향을 미치는가?
;; 아니다.
;;
;; Q. 시간에 영향을 미치는가?
;;
;; 어쨋든 require를 모두 통과해야 결과가 나옴.
;; require 순서를 조절하여 가지치기를 해두면 검사의 횟수를 줄이이면서 더 빠르게 결과를 얻을 수 있음.
;; 계산비용 자체는 distinct? 함수가 가장 크나,
;; 테스트 결과 (require (> miller cooper)) 이 제약조건이 가지치기를 크게 함으로써 시간에 가장 크게 영향을 끼쳤음.
;;
;; Q. 순서가 중요하다면, 순서를 재배치하여 더 빠른 프로그램을 만들어라. 만약 순서가 중요하지 않다면, 그 이유를 설명하라.
;;


(define env3 (setup-environment))
(define-variable! 'display (list 'primitive display) env3)
(~> '(define (require p)
       (if (not p)
           (amb)))
    (run env3)
    (check-equal? 'ok))

(~> '(define (distinct? items)
       (cond ((null? items)
              true)
             ((null? (cdr items))
              true)
             ((member (car items) (cdr items))
              false)
             (else
              (distinct? (cdr items)))))
    (run env3)
    (check-equal? 'ok))

(define expr-origin
  '(define (multiple-dwelling)
     (let ((baker (amb 1 2 3 4 5))
           (cooper (amb 1 2 3 4 5))
           (fletcher (amb 1 2 3 4 5))
           (miller (amb 1 2 3 4 5))
           (smith (amb 1 2 3 4 5)))
        
       (require (distinct? (list baker cooper fletcher miller smith)))
         
       (require (not (= baker 5)))
       (require (not (= cooper 1)))
       (require (not (= fletcher 5)))
       (require (not (= fletcher 1)))
       (require (> miller cooper))

       (require (not (= (abs (- smith fletcher)) 1)))
       (require (not (= (abs (- fletcher cooper)) 1)))

       (list (list 'baker baker)
             (list 'cooper cooper)
             (list 'fletcher fletcher)
             (list 'miller miller)
             (list 'smith smith)))))

(define expr-2
  '(define (multiple-dwelling)
     (let ((baker (amb 1 2 3 4 5))
           (cooper (amb 1 2 3 4 5))
           (fletcher (amb 1 2 3 4 5))
           (miller (amb 1 2 3 4 5))
           (smith (amb 1 2 3 4 5)))

       (require (> miller cooper))

       (require (not (= fletcher 1)))
       (require (not (= cooper 1)))

       (require (not (= (abs (- smith fletcher)) 1)))       
       (require (not (= (abs (- fletcher cooper)) 1)))

       (require (not (= fletcher 5)))
       (require (not (= baker 5)))
       (require (distinct? (list baker cooper fletcher miller smith)))

       (list (list 'baker baker)
             (list 'cooper cooper)
             (list 'fletcher fletcher)
             (list 'miller miller)
             (list 'smith smith)))))

(~> expr-origin
    (run env3)
    (check-equal? 'ok))

(racket:time
 (racket:for ([i 10])
             (~> '(multiple-dwelling)
                 (runs env3)
                 (length)
                 (check-equal? 1))))

(~> expr-2
    (run env3)
    (check-equal? 'ok))

(racket:time
 (racket:for ([i 10])
             (~> '(multiple-dwelling)
                 (runs env3)
                 (length)
                 (check-equal? 1))))

