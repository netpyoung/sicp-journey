#lang sicp
;; file: 4_40.rkt
;; 4_38, 4_39, 4_40

(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))

;; Q. distict가 있을때 없을때 경우의 수?
;; 있으면 1
;; 없으면 120
;;
;; Q. 모든 사람들을 층에 배정 후 백트래킹을 통해 이를 제거하는 방식은 매우 비효율적. 이전 제약 조건에 의해 이미 배제된 가능성만 생성하도록 하는, 훨씬 더 효율적인 비결정적 절차를 작성하고 이를 시연하라
;; (힌트: 이를 위해서는 let 표현식의 중첩이 필요하다.)
;;
;; distnct는 모든 사람들이 필요함.: (require (distinct? (list baker cooper fletcher miller smith)))
;; 대신, 사람별로 (require (not (= cooper fletcher))) / (require (not (= miller cooper))) ... 제한을 두게되면 좀 더 최적화가 됨.

(define env3 (setup-environment))
(~> '(define (require p)
       (if (not p)
           (amb)))
    (run env3)
    (check-equal? 'ok))

(~> '(define (distinct? items)
       (cond ((null? items) true)
             ((null? (cdr items)) true)
             ((member (car items) (cdr items)) false)
             (else (distinct? (cdr items)))))
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

(define expr-without-distinct
  '(define (multiple-dwelling)
     (let ((baker (amb 1 2 3 4 5))
           (cooper (amb 1 2 3 4 5))
           (fletcher (amb 1 2 3 4 5))
           (miller (amb 1 2 3 4 5))
           (smith (amb 1 2 3 4 5)))
        
       ;; (require (distinct? (list baker cooper fletcher miller smith)))
         
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

(define expr-split-let
  '(define (multiple-dwelling)
     (let ((fletcher (amb 1 2 3 4 5)))
       (require (not (= fletcher 1)))
       (require (not (= fletcher 5)))
       
       (let ((cooper (amb 1 2 3 4 5)))
         (require (not (= cooper 1)))
         (require (not (= (abs (- fletcher cooper)) 1)))
         
         (let ((miller (amb 1 2 3 4 5)))
           (require (> miller cooper))
           
           (let ((smith (amb 1 2 3 4 5)))
             (require (not (= (abs (- smith fletcher)) 1)))
             
             (let ((baker (amb 1 2 3 4 5)))
               (require (not (= baker 5)))
               
               (require (distinct? (list baker cooper fletcher miller smith)))
               (list (list 'baker baker)
                     (list 'cooper cooper)
                     (list 'fletcher fletcher)
                     (list 'miller miller)
                     (list 'smith smith)))))))))

(define expr-split-distict
  '(define (multiple-dwelling)
     (let ((fletcher (amb 1 2 3 4 5)))
       (require (not (= fletcher 1)))
       (require (not (= fletcher 5)))
       
       (let ((cooper (amb 1 2 3 4 5)))
         (require (not (= cooper 1)))
         (require (not (= (abs (- fletcher cooper)) 1)))
         
         (require (not (= cooper fletcher)))     ; for distict?
         (let ((miller (amb 1 2 3 4 5)))
           (require (> miller cooper))
           
           (require (not (= miller fletcher)))   ; for distict?
           (require (not (= miller cooper)))     ; for distict?
           (let ((smith (amb 1 2 3 4 5)))
             (require (not (= (abs (- smith fletcher)) 1)))
             
             (require (not (= smith fletcher)))  ; for distict?
             (require (not (= smith cooper)))    ; for distict?
             (require (not (= smith miller)))    ; for distict?
             (let ((baker (amb 1 2 3 4 5)))
               (require (not (= baker 5)))
               
               (require (not (= baker fletcher))) ; for distict?
               (require (not (= baker cooper)))   ; for distict?
               (require (not (= baker miller)))   ; for distict?
               (require (not (= baker smith)))    ; for distict?
               
               
               (list (list 'baker baker)
                     (list 'cooper cooper)
                     (list 'fletcher fletcher)
                     (list 'miller miller)
                     (list 'smith smith)))))))))

(~> expr-origin
    (run env3)
    (check-equal? 'ok))
(~> '(multiple-dwelling)
    (runs env3)
    (length)
    (check-equal? 1))


(~> expr-without-distinct
    (run env3)
    (check-equal? 'ok))
(~> '(multiple-dwelling)
    (runs env3)
    (length)
    (check-equal? 120))

(~> expr-origin
    (run env3)
    (check-equal? 'ok))
(racket:time
 (racket:for ([i 10])
             (~> '(multiple-dwelling)
                 (runs env3)
                 (length)
                 (check-equal? 1))))

(~> expr-split-let
    (run env3)
    (check-equal? 'ok))


(racket:time
 (racket:for ([i 10])
             (~> '(multiple-dwelling)
                 (runs env3)
                 (length)
                 (check-equal? 1))))

(~> expr-split-distict
    (run env3)
    (check-equal? 'ok))


(racket:time
 (racket:for ([i 10])
             (~> '(multiple-dwelling)
                 (runs env3)
                 (length)
                 (check-equal? 1))))

