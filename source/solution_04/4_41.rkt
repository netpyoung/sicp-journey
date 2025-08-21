#lang sicp
;; file: 4_41.rkt
;; 4_38, 4_39, 4_40, 4_41
(#%require rackunit)
(#%require "../allcode/helper/my-util.rkt")
(#%require threading)
(#%require profile)
(#%require "../allcode/ch4-4.3.3-ambeval.rkt")
(#%require (prefix r5rs: r5rs))
(#%require (prefix racket: racket))


;; Q. multiple-dwelling를 Scheme으로 풀어라.

(define env3 (setup-environment))
(define-variable! 'append (list 'primitive append) env3)

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

(~> expr-origin
    (run env3)
    (check-equal? 'ok))
(racket:time
 (~> '(multiple-dwelling)
     (runs env3)
     (check-equal? '(((baker 3) (cooper 2) (fletcher 4) (miller 5) (smith 1))))))

(define expr-x
  '(define (multiple-dwelling-scheme-for-each)
     ;; eval을 통과하기 위해 일단 do로는 안짬. scheme에는 do가 있고 continue가 없는데 continue가 있다면 더 간단할 것이다.
     ;; for-each로 짜기로 함.
     (let ((baker '(1 2 3 4 5))
           (cooper '(1 2 3 4 5))
           (fletcher '(1 2 3 4 5))
           (miller '(1 2 3 4 5))
           (smith '(1 2 3 4 5))
           (acc '()))
       (for-each (lambda (f)
                   (if (not (= f 1))
                       (if (not (= f 5))
                           (for-each (lambda (c)
                                       (if (not (= c 1))
                                           (if (not (= (abs (- f c)) 1))
                                               (for-each (lambda (m)
                                                           (if  (> m c)
                                                                (for-each (lambda (s)
                                                                            (if (not (= (abs (- s f)) 1))
                                                                                (for-each (lambda (b)
                                                                                            (if (not (= b 5))
                                                                                                (let ((val (list b c f m s)))
                                                                                                  (if (distinct? val)
                                                                                                      (set! acc (append acc (list (list 'baker b)
                                                                                                                                  (list 'cooper c)
                                                                                                                                  (list 'fletcher f)
                                                                                                                                  (list 'miller m)
                                                                                                                                  (list 'smith s))))))))
                                                                                          baker)))
                                                                          smith)))
                                                         miller))))
                                     cooper))))
                 baker)
       acc)))

(~> '(define (for-each proc items)
       ;; Exercise 4.30
       (if (null? items)
           'done
           (begin (proc (car items))
                  (for-each proc (cdr items)))))
    (run env3)
    (check-equal? 'ok))

(~> expr-x
    (run env3)
    (check-equal? 'ok))

(racket:time
 (~> '(multiple-dwelling-scheme-for-each)
     (runs env3)
     (check-equal? '(((baker 3) (cooper 2) (fletcher 4) (miller 5) (smith 1)))))
 )