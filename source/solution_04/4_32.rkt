#lang sicp
;; file: 4_32.rkt
(#%require rackunit)
(#%require threading)
(#%require profile)
(#%require "../allcode/helper/my-util.rkt")

(#%require (prefix racket: racket))
(racket:require (racket:rename-in "../allcode/ch4-4.2.2-leval.rkt"
                                  (_eval-sequence lazy:eval-sequence)))

;; 3장에서 다룬 **스트림**과 이 섹션에서 설명한 "더 게으른" **지연 리스트**의 차이점을 보여주는 몇 가지 예제를 제시해라.
;; 이 추가적인 laziness 어떻게 활용할 수 있는가?
;; 
;; (provide cons-stream)
;; (define-syntax cons-stream
;;   (syntax-rules ()
;;     [(_ A B) (r5rs:cons A (r5rs:delay B))]))
;;
;; |------------|------------------------|----------------------------------------|
;; | 스트림     | car의 즉시 평가.       | 순차적 접근과 무한 리스트 처리에 적합. |
;; | 지연 리스트| car와 cdr 모두를 지연. | 비순차적 접근에서 더 유연              |


(override-force-it! force-it-memoizing) ; memoizing없이는 solve를 푸는데 한참걸림.
(define env1 (setup-environment))

(~> '(begin 
       (define (cons x y)
         (lambda (m)
           (m x y)))
       (define (car z)
         (z
          (lambda (p q) p)))
       (define (cdr z)
         (z
          (lambda (p q) q)))

       (define (list-ref items n)
         (if (= n 0)
             (car items)
             (list-ref (cdr items) (- n 1))))

       (define (map proc items)
         (if (null? items)
             '()
             (cons (proc (car items))
                   (map proc (cdr items)))))

       (define (scale-list items factor)
         (map (lambda (x) (* x factor))
              items))

       (define (add-lists list1 list2)
         (cond ((null? list1) list2)
               ((null? list2) list1)
               (else (cons (+ (car list1) 
                              (car list2))
                           (add-lists
                            (cdr list1) 
                            (cdr list2))))))

       (define ones (cons 1 ones))

       (define integers 
         (cons 1 (add-lists ones integers))))
    (actual-value env1)
    (check-equal? 'ok))

(~> '(list-ref integers 17)
    (actual-value env1)
    (check-equal? '18))

(~> '(begin
       (define (integral integrand initial-value dt)
         (define int
           (cons initial-value
                 (add-lists (scale-list integrand dt) 
                            int)))
         int)

       (define (solve f y0 dt)
         (define y (integral dy y0 dt))
         (define dy (map f y))
         y))
    (actual-value env1)
    (check-equal? 'ok))

(define SMALL-RADIO 0.00001)
(~> '(list-ref (solve (lambda (x) x) 1 0.001) 1000)
    (actual-value env1)
    (check-= 2.716924 SMALL-RADIO))


(~> '(define (run-forever)
       (run-forever))
    (actual-value env1)
    (check-equal? 'ok))

(~> '(begin
       (cons (run-forever) 2)
       1)
    (actual-value env1)
    (check-equal? 1))

(~> '(list-ref (cons (run-forever) (cons 'helloworld nil)) 1)
    (actual-value env1)
    (check-equal? 'helloworld))
